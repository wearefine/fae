
/* global Fae, modal, FCH */

/**
 * Fae publish
 * @namespace
 */

Fae.publish = {

  ready: function() {
    this.$publishButtons          = $('.js-run-publish');
    this.$timerEl                 = $('.js-timer');
    this.lastSuccessfulDeployTime = null;
    this.pollTimeout              = null;
    this.timerInterval            = null;
    this.deployFinished           = true;
    this.buttonsEnabled           = true;

    this.refreshDeploysList();
    this.refreshChangesList();
    this.publishButtonListener();
    this.pollDeployStatus();
  },

  refreshDeploysList: function() {
    console.log('refreshDeploys');
    $.get('/admin/publish/deploys_list', function (data) {
      $('.js-deploys-list').html(data);
    });
  },

  refreshChangesList: function() {
    console.log('refreshChanges');
    $.get('/admin/publish/changes_list', function (data) {
      $('.js-changes-list').html(data);
    });
  },

  pollDeployStatus: function() {
    var _this = this;

    function poll() {
      $.get('/admin/publish/current_deploy', function (data) {
        if (data && (data.state === 'building' || data.state === 'processing')) {
          _this.notifyRunning();
          _this.deployFinished = false;
          if (!_this.timerInterval) {
            _this.startTimer(_this.lastSuccessfulDeployTime);
          }
        } else {
          _this.afterDeploy();
          if (_this.timerInterval) {
            clearInterval(_this.timerInterval);
          }
        }
      });
      _this.pollTimeout = setTimeout(poll, 3000);
    }

    poll();
  },

  publishButtonListener: function() {
    var _this = this;
    _this.$publishButtons.click(function(e) {
      e.preventDefault();
      _this.disableButtons();
      clearTimeout(_this.pollTimeout);
      var $button = $(this);
      var publish_hook_id = $button.data('publish-hook-id');
      $.post( '/admin/publish/publish_site', { publish_hook_id: publish_hook_id }, function(data) {
        // FYI Netlify returns nothing for deploy hook posts
        console.log(data);
        _this.pollDeployStatus();
        if (data && data.last_successful_admin_deploy.deploy_time) {
          _this.lastSuccessfulDeployTime = data.last_successful_admin_deploy.deploy_time;
        }
      });
    });
  },

  startTimer: function(duration) {
    var _this = this;
    var start = Date.now(),
        diff,
        minutes,
        seconds;
    function timer() {
      // get the number of seconds that have elapsed since
      // startTimer() was called
      diff = duration - (((Date.now() - start) / 1000) | 0);

      // does the same job as parseInt truncates the float
      minutes = (diff / 60) | 0;
      seconds = (diff % 60) | 0;

      if (minutes === 0 && seconds === 0) {
        $('.js-timer').text('');
        clearInterval(_this.timerInterval);
      }

      minutes = minutes < 10 ? "0" + minutes : minutes;
      seconds = seconds < 10 ? "0" + seconds : seconds;


      _this.$timerEl.text(minutes + ":" + seconds);

      if (diff <= 0) {
        // add one second so that the count down starts at the full duration
        // example 05:00 not 04:59
        start = Date.now() + 1000;
      }
    };
    // we don't want to wait a full second before the timer starts
    timer();
    _this.timerInterval = setInterval(timer, 1000);
  },

  notifyRunning: function() {
    $('.js-deploy-status').text('a deploy is running!');
  },

  notifyIdle: function() {
    $('.js-deploy-status').text('idle');
  },

  enableButtons: function() {
    var _this = this;
    if (!_this.buttonsEnabled) {
      _this.buttonsEnabled = true;
      _this.$publishButtons.prop('disabled', false);
    }
  },

  disableButtons: function() {
    var _this = this;
    if (_this.buttonsEnabled) {
      _this.buttonsEnabled = false;
      _this.$publishButtons.prop('disabled', true);
    }
  },

  resetTimerDisplay: function() {
    var _this = this;
    _this.$timerEl.text('N/A');
  },

  afterDeploy: function() {
    var _this = this;
    if (!_this.deployFinished) {
      _this.notifyIdle();
      _this.enableButtons();
      _this.resetTimerDisplay();
      _this.refreshChangesList();
      _this.refreshDeploysList();
      _this.deployFinished = true;
    }
  }

};
