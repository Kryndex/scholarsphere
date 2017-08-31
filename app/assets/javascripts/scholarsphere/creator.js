var Creator = {
  /**
   * Object that has the state and markup for the creator 
   */
  id: "",
  firstName: "",
  lastName: "",
  index: "",
  render: function () {
    var markup =
      `<div class="well creator_inputs">
    <button type="button" class="btn btn-link remove remove-creator">
      <span class="glyphicon glyphicon-remove"></span><span class="controls-remove-text">Remove</span>
    </button>
    <label for="generic_work_creators_${this.index}_first_name">First Name</label>
    <input type="text" name="generic_work[creators][${this.index}][first_name]" id="generic_work[creators][${this.index}][first_name]" class="form-control string required creator-first-name creator" value="${this.firstName}">
    <label for="generic_work_creators_${this.index}_last_name">Last Name</label>
    <input type="text" name="generic_work[creators][${this.index}][last_name]" id="generic_work[creators][${this.index}][last_name]" class="form-control string required creator-last-name creator" value="${this.lastName}">
  </div>`
    return markup
  }
}

var CreatorBehavior = {
  /**
   * Object for activating add/remove functionality 
   */
  activateAddButton: function () {
    $('.add-creator').on('click', function () {
      var creator = Object.create(Creator)
      creator.index = $('.creator_inputs').length
      $('.creator_container').append(creator.render())
    })
  },
  activateRemoveButton: function () {
    $('.base-terms').on('click', '.remove-creator', function () {
      if ($('.creator_inputs').length > 1) {
        $(this).parent().remove()
      } else {
        $(this).parent().find('.string').each(function () { $(this).val("") })
      }
    })
  }
}

Blacklight.onLoad(function () {
  CreatorBehavior.activateAddButton()
  CreatorBehavior.activateRemoveButton()
})