jest.unmock('./foreman_hosts');
const hosts = require('./foreman_hosts');
const $ = require('jquery');
const tfm = {
  tools: {
    showSpinner: function () {
    }
  }
};

describe('os_selected', () => {
  beforeEach(() => {
    window.Jed = { sprintf: function (input) { return input; } };
    window.__ = function (input) { return input; };

    tfm.tools.showSpinner = function () {}; // mock it out
    document.body.innerHTML = `<div>
      </div>`;
  });

  it('attribute hash holds the default attributes', () => {
    let responseVar = {};

    hosts['update_provisioning_image'] = function () {}; // mock it out
    $.ajax = function (data) {};
    hosts['attribute_hash'] = function (data) {
      responseVar.attrs = data;
    };

    hosts.os_selected();
    expect(responseVar.attrs).toBe(['operatingsystem_id', 'organization_id', 'location_id']);
  });

  it('adds the plugin_edit_attributes', () => {
    let responseVar = {};

    hosts['update_provisioning_image'] = function () {}; // mock it out
    $.ajax = function (data) {};
    hosts['attribute_hash'] = function (data) {
      responseVar.attrs = data;
    };

    hosts.plugin_edit_attributes.os = ['foo'];

    hosts.os_selected();
    expect(responseVar.attrs).toBe(['operatingsystem_id', 'organization_id', 'location_id', 'foo']);
  });

});
