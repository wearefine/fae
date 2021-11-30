
/* global Fae, modal, FCH */

/**
 * Fae publish
 * @namespace
 */

Fae.publish = {

  ready: function() {
    if (!$('body').hasClass('publish')) return false;
    console.log('ass');
    this.$publishButtons          = $('.js-run-build');
    this.$timerEl                 = $('.js-timer');
    this.lastSuccessfulDeployTime = null;
    this.pollTimeout              = null;
    this.pollInterval             = 5000;
    this.timerInterval            = null;
    this.deployFinished           = true;
    this.buttonsEnabled           = true;

    this.refreshProductionChangesList();
    this.refreshStagingChangesList();
    this.publishButtonListener();
    this.pollDeployStatus();

    this.notifyIdle();
  },

  publishButtonListener: function() {
    var _this = this;
    _this.$publishButtons.click(function(e) {
      e.preventDefault();
      _this.disableButtons();
      var $button = $(this);
      var build_hook_type = $button.data('build-hook-type');
      $.post( '/admin/publish/publish_site', { build_hook_type: build_hook_type }, function(data) {
        // FYI Netlify returns nothing for deploy hook posts, a deploy ID would be nice to enable
        // tracking of the deploy, so our workaround is to just keep a poll running on the deploys list.
      });
    });
  },

  refreshDeploysListAndStatuses: function() {
    var _this = this;
    $.get('/admin/publish/deploys_list', function (data) {
      if (data) {
        _this.drawTable(data);
        _this.stateChecks(data);
      }
    });
  },

  refreshProductionChangesList: function() {
    $.get('/admin/publish/changes_list?env=production', function (data) {
      $('.js-production-changes-list').html(data);
    });
  },

  refreshStagingChangesList: function() {
    $.get('/admin/publish/changes_list?env=staging', function (data) {
      $('.js-staging-changes-list').html(data);
    });
  },

  pollDeployStatus: function() {
    var _this = this;
    function poll() {
      _this.refreshDeploysListAndStatuses();
      _this.pollTimeout = setTimeout(poll, _this.pollInterval);
    }
    poll();
  },

  notifyRunning: function() {
    $('.js-deploy-status').text('A deploy is running!');
  },

  notifyIdle: function() {
    $('.js-deploy-status').text('Idle');
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

  afterDeploy: function() {
    var _this = this;
    if (!_this.deployFinished) {
      _this.notifyIdle();
      _this.enableButtons();
      _this.refreshProductionChangesList();
      _this.refreshStagingChangesList();
      _this.deployFinished = true;
    }
  },

  drawTable: function(data) {
    var _this = this;
    var $theTbody = $('.js-deploys-list').find('tbody');
    $theTbody.find('tr').remove();
    $.each(data, function(i, deploy) {
      $theTbody.append(
        $('<tr>').append([
          $('<td>').text(deploy.title),
          $('<td>').text(moment(deploy.updated_at).format('MM/DD/YYYY h:mm a')),
          $('<td>').text(_this._deployDuration(deploy)),
          $('<td>').text(deploy.branch),
          $('<td>').text(_this._valCheck(deploy.committer)),
          $('<td>').text(deploy.context),
          $('<td class="state">').text(deploy.state),
          $('<td>').text(_this._valCheck(deploy.error_message)),
        ])
      );
    });
  },

  stateChecks: function(data) {
    var _this = this;
    if (_this._deployIsRunning(data)) {
      _this.notifyRunning();
      _this.disableButtons();
      _this.deployFinished = false;
    } else {
      _this.afterDeploy();
    }
  },

  _valCheck: function(val) {
    if (val !== null) return val;
  },

  _deployIsRunning: function(data) {
    var running = false;
    $.each(data, function(i, deploy) {
      if(['error', 'ready'].indexOf(deploy.state) === -1) {
        running = true;
        return false;
      }
    });
    return running;
  },

  _deployDuration: function(deploy) {
    if (deploy.deploy_time === null) {
      return '...';
    } else {
      return moment.utc(parseInt(deploy.deploy_time)*1000).format('HH:mm:ss');
    }
  }

};

