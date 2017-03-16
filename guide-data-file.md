(DRAFT/INCOMPLETE) How to integrate a Registers-backed Location Picker into a Rails project
===

This guide will show you how to:

- Use the Location Picker Register data file.
- Populate a location picker [autocomplete field](https://github.com/alphagov/accessible-typeahead).

Other things you might be interested in:

- [guide-api-client.md](https://github.com/openregister/rails-picker-example/blob/guide-api-client/guide-api-client.md): A guide about accomplishing this task using `openregister-ruby`;

## What you need

This guide assumes you have a service that is written in Ruby on Rails and asks users to select a country or territory (a **location**). Something like this:

![An image consisting of a web form. There is a title that asks "What is your country of birth." There is a select box that has the preselected value of "United Kingdom". There is a submit button at the bottom.](example-form.png)

TODO: Style the example app to look GDSy.

At the end, your location picker will be populated automatically with data from Registers, and will look and function more like this:

![An animated image consisting of a web form. There is a label that reads "Country of birth." There is an empty text field. The text field is selected, and the characters "U N I" are typed in. A menu appears under the text field, it contains matching countries: "United Kingdom," "United States," "United Arab Emirates," "Tunisia." The first option, "United Kingdom", is clicked on. The text field now updates to contain "United Kingdom." The animation loops from the beginning.](location-picker-example.gif)

TODO: Replace with a gif of the actual location picker running in the same example app.

## The example application

To illustrate this process, this guide will use this application as a base: [openregister/rails-picker-example](https://github.com/openregister/rails-picker-example).

Key things to know about the example app:

- It's barebones and based on the starter `rails new`, and a `rails generate`d `Answer` model/view/controller.
- The application asks users to provide their country of birth. This information is saved as an `Answer`.
- Users are provided with a select box that submits the relevant location code as part of an HTML form `POST` request.
- The location codes are persisted as [ISO 3166-1 alpha-2 codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2#Officially_assigned_code_elements). So if a user picks "United Kingdom," they submit `location_code: "GB"`.
- The list of recognised locations is defined in `app/helpers/answers_helper.rb` and consists of a hardcoded array of location names and codes.

## The process

We'll be updating the example app by doing the following:

- We'll replace the hardcoded array of locations with Registers data.
- We'll enhance the frontend into an [accessible autocomplete](https://github.com/alphagov/accessible-typeahead) widget.

### Pulling in Registers data

The app currently defines the list of locations in `app/helpers/answers_helper.rb`. It's a simple hardcoded array of names and location codes, which get mapped into a slightly different array (to work in an `options_for_select` call):

```ruby
def locations_for_select
  [
    { "name": "Afghanistan", "location_code": "AF" },
    { "name": "Albania", "location_code": "AL" },
    # …snip…
  ].map { |location|
    [location[:name], location[:location_code]]
  }
end
```

To get Location Picker data from Registers, we can pull in two files:

- [location-picker-canonical-list.json](public/location-picker-canonical-list.json): A list of every canonical country and territory;
- [location-picker-graph.json](public/location-picker-graph.json): A directed acyclic graph of mappings between locations and abbreviations, synonyms, endonyms, typos.

Copy those two files to the `public/` folder in your application.

The `location-picker-canonical-list.json` file contains an array of arrays containing the location names and ISO codes:

```ruby
> JSON.parse(File.read('public/location-picker-canonical-list.json'))
[["Abu Dhabi", "AE-AZ"], ["Afghanistan", "AF"], …]
```

TODO: Change to use curies instead.

We can use this array directly as the data source for our select:

```ruby
def locations_for_select
  JSON.parse(File.read('public/location-picker-canonical-list.json'))
end
```

The app is now successfully pulling in Registers data to display the list of countries. For users that don't have JavaScript, this is the experience they will continue receiving, but now it's time to make it better.

TODO: Discuss migrating from existing result formats (names, ISO codes) to curies.

TODO: Discuss keeping the data up to date. Job included with the gem to check for new versions? Ask people to do it periodically manually?

TODO: Discuss what to do when users don't rely on ISO 3166-1 codes as keys.

TODO: Discuss exclusions here? Provide helper methods?

### Progressively enhancing to a typeahead

The example application uses location picker data in a simple HTML `<select>` element:

```html
# app/views/answers/_form.html.erb

<%= f.label :location_code, "Enter your country of birth", for: "location_picker" %>
<%= f.select :location_code, options_for_select(locations_for_select, @answer.location_code), {}, id: "location_picker" %>
```

We need to include this CSS and JS in our `layouts/application.html.erb`:

```html
<!-- In your <head> -->
<link rel="stylesheet" href="https://unpkg.com/accessible-typeahead@0.3.1/examples/styled.css" />

<!-- At the end of your <body> -->
<script src="TODO: LINK TO SUGGESTION ENGINE SCRIPT HERE"></script>
<script src="https://unpkg.com/accessible-typeahead@0.3.1"></script>
```

TODO: Replace link to suggestion engine in above.

TODO: Provide a gem / better ways to obtain / vendor these.

In our main `application.js`, we can do this:

```js
var pathToGraph = 'public/location-picker-graph.json'
var selectId = '#location_picker'
AccessibleTypeahead({
  enhanceSelectEl: document.getElementById(selectId),
  source: locationPickerSuggestions(pathToGraph)
})
```

TODO: Allow the typeahead to enhance a `<select>` menu in-place, the `enhanceSelectEl` option.

TODO: Create the `locationPickerSuggestions` function.

That should be it. This will render the same `<select>` menu as before on the server, but hides it and progressively enhances to a typeahead when JavaScript kicks in. When the user selects something in the typeahead, the hidden `<select>` menu is still updated, so everything works as before.

TODO: Update select menu when an option is selected in the typeahead.
