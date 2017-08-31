var creatorAutocomplete = {
  /**
   * Object for setting up Typeahead and Bloodhound
   */
  all: {},
  initBloodhound: function () {
    this.all = new Bloodhound({
      datumTokenizer: Bloodhound.tokenizers.obj.whitespace,
      queryTokenizer: Bloodhound.tokenizers.whitespace,
      prefetch: {
        url: '../../creators/all/'
      },
      remote: {
        url: '../../creators/all'
      }
    })
    this.all.initialize()
  },
  activateTypeahead: function (index) {
    $(`.creator-first-name:eq(${index})`).typeahead({
      minLength: 3,
      highlight: true
    },
      {
        name: 'my-dataset',
        source: this.all
      })
  },
  typeaheadSelect: function (index) {
    $(`.creator-first-name:eq(${index})`).bind('typeahead:select', function (ev, suggestion) {
      $(`.creator-first-name:eq(${index})`).val(suggestion.first_name)
      $(`.creator-last-name:eq(${index})`).val(suggestion.last_name)
      $(`.creator:eq(${index})`).attr('readonly', 'readonly')
    })
  }
}

Blacklight.onLoad(function () {
  creatorAutocomplete.initBloodhound(0)
  creatorAutocomplete.activateTypeahead(0)
  creatorAutocomplete.typeaheadSelect(0)
})