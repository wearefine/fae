# Overriding Markdown Helper

If, for some reason, you need to override the default markdown helper content, you may do so by following these steps.


To you views folder, add a `fae` folder and in that folder, add an `application` folder. The path will be `views/fae/application`.
To `application` add `_markdown_helper.slim`. The contents are as follows and you may update them however you wish.

```slim
.markdown-hint
  .markdown-hint-wrapper
    h3 Markdown Options

    h4 Links
    p
      | To link text, place a [bracket] around the link title and use a (/url) to house the url.
      br
      | Internal Link: [link to about](/about)
      br
      | External link: [link to about](http://www.google.com/about)

    h4 Formatting
    p
      | Emphasize text in a variety of ways by placing **asterisks** to bold, _underscores_ to italicize.
      br
      | Bold **bold**
      br
      | Italicize _italic

    h4 Headers
    p
      | Use up to six hashtags to identify the importance of the section header.
      br
      | Page Header: # Page Header
      br
      | Sub Header: ## Sub Header

    h4 List
    p
      | Format lists by swapping out the characters that lead the list item.
      br
      span Bulleted List:
      br
      == ['* bullet', '* bullet 2'].join('<br />')
      br
      span Numbered List
      == ['1. line item', '2. line item'].join('<br />')

    h4 Paragraph break
    p Adding a blank line in between your paragraphs makes a paragraph break.
```
---