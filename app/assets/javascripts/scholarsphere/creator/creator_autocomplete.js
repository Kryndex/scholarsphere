var creatorAutocomplete = {
  /**
   * Object for setting up Typeahead and Bloodhound
   */
  all: {},
  initBloodhound: function () {
    this.all = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace('first_name','last_name'),
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      sufficient: 0,  
      limit:10,      
      prefetch: {
        url: '../../creators/all/'
      }
    })
    this.all.initialize()
  },
  activateTypeahead: function (index) {
    $('#find_creator').typeahead({
      highlight: true
    },
      {
        name: 'creators',
        display: 'first_name',
        source: this.all,
        templates: {
          empty: '<p>  Unable to find any results  </p>',
          suggestion: function (data) {
            return '<p>' + data.first_name + ' ' + data.last_name + '</p>'
          }
        },
        display: function (data) {
          return data.first_name + ' ' + data.last_name
        }
      })
  },
  typeaheadSelect: function (index) {
    $('#find_creator').bind('typeahead:select', function (ev, suggestion) {
      var creator = Object.create(Creator)
      creator.firstName = suggestion.first_name
      creator.lastName = suggestion.last_name
      creator.index = $('.creator_inputs').length
      creator.readonly = 'readonly'
      $('.creator_container').append(creator.render())
    })
  },
  typeaheadClose: function () {
    $('#find_creator').bind('typeahead:close', function (ev, suggestion) {
      $('#find_creator').val('')
    })
  }
}

Blacklight.onLoad(function () {
  creatorAutocomplete.initBloodhound()
  creatorAutocomplete.activateTypeahead()
  creatorAutocomplete.typeaheadSelect()
  creatorAutocomplete.typeaheadClose()
})
