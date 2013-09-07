var relationshipTemplate = _.template($('#relationship_template').html()),
  dependentTemplate = _.template($('#dependent_template').html()),
  resetForm = function ($form) {
    $form.find('input:text, input:password, input:file, input:number, select, textarea').val('');
    $form.find('input:radio, input:checkbox')
      .removeAttr('checked').removeAttr('selected');
  },
  countFieldsets = function () {
    var $fieldsets = $('fieldset');
    $fieldsets.each(function (i, el) {
      var rI,
        $applicantRelationshipFields = $('.applicant-relationship-fields', el);
      $('.applicant-number', el).text(i + 1);
      for (rI = 0; rI < i; rI += 1) {
        if ($applicantRelationshipFields.find('.form-row').length < i) {
          $applicantRelationshipFields
            .append(relationshipTemplate({self: i + 1, relation: rI + 1}));
        }
      }
      $('label, input', el).each(function (j, formEl) {
        var $formEl = $(formEl);
        _.each(['for', 'id', 'name'], function (at) {
          var val = $formEl.attr(at);
          if (val) {
            $formEl.attr(at, val.replace(/^applicant_[0-9]+/, 'applicant_' + (i + 1)));
          }
        });
      });
      $(el).toggleClass('last-applicant', i === $fieldsets.length - 1);
    });
    $('.filer-2-row').toggle($fieldsets.length > 1);
  },
  uniform = function () {
    $('input[type=checkbox], select').uniform({selectAutoWidth: false});
  };

$(document).on('change', '[type=checkbox]', function () {
  var $this = $(this),
    checked = $(this).is(':checked'),
    $parent = $this.closest('.checker').parent('.form-row-expandable'),
    exclusive = $this.data('exclusive');
  $parent.toggleClass('form-row-expanded', checked);
  $parent.children('.form-row-expandable-fields').slideToggle(checked);
  if (exclusive) {
    $this.closest('fieldset').find('input[data-exclusive=' + exclusive + ']:checked').not($this)
      .attr('checked', false);
  }
  $.uniform.update();
}).on('click', '.add-applicant', function () {
  var $fieldsets = $('fieldset'),
    $filers = $('.filer'),
    $newFieldset,
    $newDependent;
  $.uniform.restore('input[type=checkbox], select');
  $newFieldset = $fieldsets.first().clone();
  $newFieldset.removeClass('first-applicant');
  resetForm($newFieldset);
  $newFieldset.hide();
  $fieldsets.last().after($newFieldset);
  $newFieldset.slideDown();
  countFieldsets();
  $filers.append('<option value=""></option>');
  $newDependent = $(dependentTemplate({num: $fieldsets.length}));
  $newDependent.find('select').append($filers.first().clone().children());
  $('.dependent-fields').append($newDependent);
  uniform();
}).on('click', '.remove-applicant', function () {
  var $fieldset = $(this).closest('fieldset');
  if ($('fieldset').length > 1) {
    $fieldset.slideUp(function () {
      $fieldset.remove();
      countFieldsets();
      $('.filer').each(function () {
        $('option', this).last().remove();
        $('.dependent-fields .form-row').last().remove();
        $.uniform.update(this);
      });
    });
  }
}).on('keyup', '.applicant-id-field', function () {
  var $field = $(this),
    index = $('.applicant-id-field').index($field);
  $('.filer').each(function () {
    var val = $field.val()
    $('option', this).eq(index + 1).val(val).text(val);
    $.uniform.update(this);
  });
}).on('submit', '#application_form', function() {
    event.preventDefault();
    var application = new MAGI.Application($(this).serializeObject(), $('fieldset').length);
    console.log(JSON.stringify(application, undefined, 2));
    var endpoint = new MAGI.Endpoint("/determinations/eval.json");
    endpoint.submit(application, function(response) {
      $("#application_form").hide();
      $("body").append(response)
      console.log(response);
    });
    return false;
});

$(function () {
  $('.date').mask('99 / 99 / 9999');

  uniform();
});