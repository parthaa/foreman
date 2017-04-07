import $ from 'jquery';
export let plugin_edit_attributes = {
  architecture: [],
  os: [],
  medium: [],
  image: []
};

export function architecture_selected(element){
  let url = $(element).attr('data-url');
  let type = $(element).attr('data-type');
  let attrs = {};
  let attrs_to_post = ['architecture_id', 'organization_id', 'location_id'].concat(window.tfm.hosts.plugin_edit_attributes.architecture);
  attrs[type] = attribute_hash(attrs_to_post);
  tfm.tools.showSpinner();
  $.ajax({
    data: attrs,
    type:'post',
    url: url,
    complete: function(){
      reloadOnAjaxComplete(element);
    },
    success: function(request) {
      $('#os_select').html(request);
    }
  })
}

export function os_selected(element){
  let url = $(element).attr('data-url');
  let type = $(element).attr('data-type');
  let attrs = {};
  let attrs_to_post = ['operatingsystem_id', 'organization_id', 'location_id'].concat(window.tfm.hosts.plugin_edit_attributes.os);
  attrs[type] = attribute_hash(attrs_to_post);
  tfm.tools.showSpinner();
  $.ajax({
    data: attrs,
    type:'post',
    url: url,
    complete: function(){
      reloadOnAjaxComplete(element);
    },
    success: function(request) {
      $('#media_select').html(request);
      reload_host_params();
      reload_puppetclass_params();
    }
  });
  update_provisioning_image();
}

export function update_provisioning_image(){
  let compute_id = $('[name$="[compute_resource_id]"]').val();
  let arch_id = $('[name$="[architecture_id]"]').val();
  let os_id = $('[name$="[operatingsystem_id]"]').val();
  if((compute_id == undefined) || (compute_id == "") || (arch_id == "") || (os_id == "")) return;
  let image_options = $('#image_selection select').empty();
  $.ajax({
      data: {'operatingsystem_id': os_id, 'architecture_id': arch_id},
      type:'get',
      url: foreman_url('/compute_resources/'+compute_id+'/images'),
      dataType: 'json',
      success: function(result) {
        $.each(result, function() {
          image_options.append($("<option />").val(this.image.uuid).text(this.image.name));
        });
        if (image_options.find('option').length > 0) {
          if ($('#host_provision_method_image')[0].checked) {
            if ($('#provider').val() == 'Libvirt') {
              libvirt_image_selected(image_options);
            } else if ($('#provider').val() == 'Ovirt') {
              let template_select = $('#host_compute_attributes_template');
              if (template_select.length > 0) {
                template_select.val(image_options.val());
                ovirt_templateSelected(image_options);
              }
            }
          }
        }
      }
    })
}

export function medium_selected(element){
  let url = $(element).attr('data-url');
  let type = $(element).attr('data-type');
  let attrs = {};
  let attrs_to_post = ['medium_id', 'operatingsystem_id', 'architecture_id'].concat(window.tfm.hosts.plugin_edit_attributes.medium);
  attrs[type] = attribute_hash(attrs_to_post);
  attrs[type]["use_image"] = $('*[id*=use_image]').attr('checked') == "checked";
  $.ajax({
    data: attrs,
    type:'post',
    url: url,
    success: function(request) {
      $('#image_details').html(request);
    }
  })
}

export function use_image_selected(element){
  let url = $(element).attr('data-url');
  let type = $(element).attr('data-type');
  let attrs = {};
  let attrs_to_post = ['medium_id', 'operatingsystem_id', 'architecture_id', 'model_id'].concat(window.tfm.hosts.plugin_edit_attributes.image);
  attrs[type] = attribute_hash(attrs_to_post);
  attrs[type]['use_image'] = ($(element).attr('checked') == "checked");
  $.ajax({
    data: attrs,
    type: 'post',
    url:  url,
    success: function(response) {
      let field = $('*[id*=image_file]');
      if (attrs[type]["use_image"]) {
        if (field.val() == "") field.val(response["image_file"]);
      } else
        field.val("");

      field.attr("disabled", !attrs[type]["use_image"]);
    }
  });
}

export function reload_host_params(){
  let host_id = $("form").data('id');
  let url = $('#params-tab').data('url');
  let data = serializeForm().replace('method=patch', 'method=post');
  if (url.length > 0) {
    data = data + '&host_id=' + host_id;
    load_with_placeholder('inherited_parameters', url, data);
  }
}

export function reload_puppetclass_params(){
  let host_id = $("form").data('id');
  let url2 = $('#params-tab').data('url2');
  let data = serializeForm().replace('method=patch', 'method=post');
  if (url2.match('hostgroups')) {
    data = data + '&hostgroup_id=' + host_id
  } else {
    data = data + '&host_id=' + host_id
  }
  load_with_placeholder('inherited_puppetclasses_parameters', url2, data)
}

export function load_with_placeholder(target, url, data){
  if(url==undefined) return;
  let placeholder = $('<tr id="' + target + '_loading" >'+
            '<td colspan="4">'+ spinner_placeholder(__('Loading parameters...')) + '</td></tr>');
        $('#' + target + ' tbody').replaceWith(placeholder);
        $.ajax({
          type:'post',
          url: url,
          data: data,
          success:
            function (result, textstatus, xhr) {
              placeholder.closest('#' + target ).replaceWith($(result));
              mark_params_override();
            }
        });
}
