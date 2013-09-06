var resetForm = function ($form) {
    $form.find('input:text, input:password, input:file, select, textarea').val('');
    $form.find('input:radio, input:checkbox')
      .removeAttr('checked').removeAttr('selected');
  },
  countFieldsets = function () {
    var $fieldsets = $('fieldset');
    $fieldsets.each(function (i, el) {
      var rI,
        $applicantRelationshipFields = $('.applicant-relationship-fields', el),
        relationshipTemplate = _.template($('#relationship_template').html());
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
      $(el).toggleClass('last-applicant', i === $fieldsets.length - 1)
    });
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
    $newFieldset;
  $.uniform.restore('input[type=checkbox], select');
  $newFieldset = $fieldsets.first().clone();
  $newFieldset.removeClass('first-applicant');
  resetForm($newFieldset);
  $newFieldset.hide();
  $fieldsets.last().after($newFieldset);
  $newFieldset.slideDown();
  countFieldsets();
  uniform();
}).on('click', '.remove-applicant', function () {
  var $fieldset = $(this).closest('fieldset');
  if ($('fieldset').length > 1) {
    $fieldset.slideUp(function () {
      $fieldset.remove();
    });
    countFieldsets();
  }
}).on('submit', '#application_form', function() {
  event.preventDefault();
  var application = new MAGI.Application($(this).serializeObject(), $('fieldset').length);
  return false;
});

$(uniform);