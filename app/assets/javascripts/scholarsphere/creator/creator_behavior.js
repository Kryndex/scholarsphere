var CreatorBehavior = {
    /**
     * Object for activating add/remove functionality
     */
  activateAddButton: function () {
    $('.add-creator').on('click', function () {
      var creator = Object.create(Creator)

      CreatorIndex.index += 1
      creator.index = CreatorIndex.index

      var template = $('#creator_template').html()
      var render = Mustache.render(template, creator)
      $('.creator_container').append(render)
    })
  },
  activateRemoveButton: function () {
    $('.creator_inputs').on('click', '.remove-creator', function () {
        $(this).parent().remove()
    })
  }
}

Blacklight.onLoad(function () {
  CreatorBehavior.activateAddButton()
  CreatorBehavior.activateRemoveButton()
  CreatorIndex.index = $('.creator_inputs').length - 1
})
