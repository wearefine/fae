
/* global Fae, modal, FCH */

/**
 * Fae publish
 * @namespace
 */

Fae.publish = {

  ready: function() {
    if (!$('body').hasClass('publish')) return false;
    this.$publishButtons          = $('.js-run-build');
    this.deployFinished           = true;
    this.buttonsEnabled           = true;
    this.pollTimeout              = null;
    this.pollInterval             = 5000;
    this.idleStates               = ['ready', 'error']

    this.publishButtonListener();
    this.pollDeployStatus();
    this.notifyIdle();
    this.refreshDeploysListAndStatuses();
  },

  publishButtonListener: function() {
    var _this = this;
    _this.$publishButtons.click(function(e) {
      e.preventDefault();
      _this.disableButtons();
      var $button = $(this);
      var build_hook_type = $button.data('build-hook-type');
      $.post( '/admin/publish/publish_site', { build_hook_type: build_hook_type }, function(data) {
        // Netlify returns nothing for deploy hook posts
      });
    });
  },

  refreshDeploysListAndStatuses: function() {
    var _this = this;
    $.get('/admin/publish/deploys_list', function (data) {
      if (data) {
        _this.drawTables(data);
        _this.stateChecks(data);
      }
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
    $('.deploying-heading').addClass('running');
  },

  notifyIdle: function() {
    $('.deploying-heading').removeClass('running');
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
      _this.deployFinished = true;
    }
  },

  drawTables: function(data) {
    var _this = this;
    var runningDeploys = _this.getRunningDeploys(data);
    var pastDeploys = _this.getPastDeploys(data);
    $('.js-deploys-list').find('tbody').find('tr').remove();
    _this.injectTableDeployData(runningDeploys, $('.js-deploys-list.running').find('tbody'));
    _this.injectTableDeployData(pastDeploys, $('.js-deploys-list.past').find('tbody'));
  },

  getRunningDeploys: function(data) {
    var _this = this;
    return data.filter(function(deploy) {
      return $.inArray(deploy.state, _this.idleStates) === -1;
    });
  },

  getPastDeploys: function(data) {
    var _this = this;
    return data.filter(function(deploy) {
      return $.inArray(deploy.state, _this.idleStates) !== -1;
    });
  },

  injectTableDeployData: function(deploys, $tbody) {
    var _this = this;
    $.each(deploys, function(i, deploy) {
      $tbody.append(
        $('<tr>').append([
          $('<td>').text(deploy.commit_ref !== null ? 'FINE dev update' : deploy.title),
          $('<td>').text(moment(deploy.updated_at).format('MM/DD/YYYY h:mm a')),
          $('<td>').text(_this.deployDuration(deploy)),
          $('<td>').text(_this.deployEnvironment(deploy)),
          $('<td>').text(_this.valCheck(deploy.error_message)),
        ])
      );
    });
  },

  stateChecks: function(data) {
    var _this = this;
    if (_this.deployIsRunning(data)) {
      _this.notifyRunning();
      _this.disableButtons();
      _this.deployFinished = false;
    } else {
      _this.afterDeploy();
    }
  },

  valCheck: function(val) {
    if (val !== null) return val;
  },

  deployIsRunning: function(data) {
    var _this = this;
    var running = false;
    $.each(data, function(i, deploy) {
      if(_this.idleStates.indexOf(deploy.state) === -1) {
        running = true;
        return false;
      }
    });
    return running;
  },

  deployDuration: function(deploy) {
    if (deploy.deploy_time === null) {
      return '–';
    } else {
      return moment.utc(parseInt(deploy.deploy_time)*1000).format('HH:mm:ss');
    }
  },

  deployEnvironment: function(deploy) {
    if (deploy.branch === 'master' || deploy.branch === 'main') {
      return 'Production';
    }
    return deploy.branch.charAt(0).toUpperCase() + deploy.branch.slice(1);
  }

};

