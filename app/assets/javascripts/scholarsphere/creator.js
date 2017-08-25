Blacklight.onLoad(function() {
  $('.add-creator').on('click',function() {
    var creatorInput = $(this).prev().find('.creator_inputs').first()
    creatorInput.wrap('<div>')
    $(this).prev().append(incrementCreator(creatorInput.parent().html()))
  })
  $('.base-terms').on('click', '.remove-creator', function() {
    if ($('.creator_inputs').length > 1) {
    $(this).parent().remove()
    } else {
      $(this).parent().find('.string').each(function() { $(this).val("") })
    }
  })
})

function incrementCreator(creatorInput) {
  var inputCount = $('.creator_inputs').length
  return creatorInput.replace(/0/g,inputCount)
}