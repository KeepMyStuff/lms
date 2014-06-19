# Guidelines

## Directory Layout
- **/:** code shared between client/server
	- **Server:** server side code (coffeescript files)
	- **Client:** client side code
		- **View:** HTML and CSS
		- **Flat UI** Bootstrap base theme

## Routes and views
Each route's name must match the template one. Do not use camel case or
underscore: separate words with a dash.
Store templates in a .html file with the same name as for the less style.
Put these inside a directory in `views` with the name of the template.

Name less style files as `*.import.less` to prevent meteor from loading
them automatically. Then to load the style use `@import` in `main.less`.

## Applying style to a template
Inside any template put a main container with the template's name as id then
use this as a reference for applying style to all children elements in the less
file. Without relatives selectors you may override style in other templates.

## Code
For html/less use hard tabs for indentation and soft tabs (spaces) for align.
See [this](http://lea.verou.me/2012/01/why-tabs-are-clearly-superior/).

For coffeescript follow coffeelint suggestions.
