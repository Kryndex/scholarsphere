var CreatorBehavior = {
    /**
     * Object for activating add/remove functionality
     */
  activateAddButton: function () {
    $('.add-creator').on('click', function () {
      var creator = Object.create(Creator)
      creator.index = $('.creator_inputs').length
      var template = $('#creator_template').html()
      var render = Mustache.render(template, creator)
      $('.creator_container').append(render)
    })
  },
  activateRemoveButton: function () {
    $('.base-terms').on('click', '.remove-creator', function () {
        $(this).parent().remove()
    })
  }
}

Blacklight.onLoad(function () {
  CreatorBehavior.activateAddButton()
  CreatorBehavior.activateRemoveButton()
})
