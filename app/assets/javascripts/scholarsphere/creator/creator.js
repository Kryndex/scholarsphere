var Creator = {
  /**
   * Object that has the state and markup for the creator
   */
  id: '',
  firstName: '',
  lastName: '',
  index: '',
  readonly: '',
  render: function () {
    var markup =
      `<div class="well creator_inputs">
    <button type="button" class="btn btn-link remove remove-creator">
      <span class="glyphicon glyphicon-remove"></span><span class="controls-remove-text">Remove</span>
    </button>
    <label for="generic_work_creators_${this.index}_first_name">First Name</label>
    <input type="text" ${this.readonly} name="generic_work[creators][${this.index}][first_name]" id="generic_work[creators][${this.index}][first_name]" class="form-control string required creator-first-name creator" value="${this.firstName}">
    <label for="generic_work_creators_${this.index}_last_name">Last Name</label>
    <input type="text" ${this.readonly} name="generic_work[creators][${this.index}][last_name]" id="generic_work[creators][${this.index}][last_name]" class="form-control string required creator-last-name creator" value="${this.lastName}">
  </div>`
    return markup
  }
}
