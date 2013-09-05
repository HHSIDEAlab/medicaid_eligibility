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
      while ($applicantRelationshipFields.find('form-row').length > i) {

      }
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
  };

$(document).on('change', '[type=checkbox]', function () {
  var $this = $(this),
    checked = $(this).is(':checked'),
    $parent = $this.parent('.form-row-expandable'),
    exclusive = $this.data('exclusive');
  $parent.toggleClass('form-row-expanded', checked);
  $parent.find('.form-row-expandable-fields').slideToggle(checked);
  if (exclusive) {
    $this.closest('fieldset').find('input[data-exclusive=' + exclusive + ']').not($this)
      .attr('checked', !checked);
  }
}).on('click', '.add-applicant', function () {
  var $fieldsets = $('fieldset'),
    $newFieldset = $fieldsets.first().clone();
  $newFieldset.removeClass('first-applicant');
  resetForm($newFieldset);
  $fieldsets.last().after($newFieldset);
  countFieldsets();
}).on('click', '.remove-applicant', function () {
  if ($('fieldset').length > 1) {
    $(this).closest('fieldset').remove();
    countFieldsets();
  }
});