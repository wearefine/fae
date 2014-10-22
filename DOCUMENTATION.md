

```
R    -  required
r    -  restricted
O    -  optional
```

```
I    - input only
A    - association only
I/A  - input or association
```


##documentation
###fae_input (**I**) & fae_association (**A**)
* **O**  __input_class__: string

* **O**  __wrapper_class__: string

* **O**  __validate__: boolean

* **O**  __label__: string

* **O**  __hint__: string
    + can’t be used with dark_hint

* **O**  __dark_hint__: string
    + can’t be used with hint

* **O**  __order_by__: string
    + defaults to ‘name'
    + must be an attribute
    + the collection option overrides order_by

* **O**  __prompt__: string
    + defaults to 'Select One’

* **O**  __order_direction__: string
    + defaults to ‘ASC’
    + must be ‘ASC’ or ‘DESC’



###fae_prefix (**I**)

* **R**  __prefix__: string
* **O**  __icon__: boolean



###fae_suffix (**I**)

* **R**  __suffix__: string
* **O**  __icon__: boolean


###fae_video_url (**I**)

* **r**  __helper_text__: string
* **r**  __hint__: string


###fae_radio (**I/A**)

* **O**  __type__: string

    + defaults to stacked
    + must be ‘inline’ or ‘stacked’



###fae_checkbox (**I/A**)

* **O**  __type__: string

    + defaults to stacked
    + must be ‘inline’ or ‘stacked’



###fae_pulldown (**I/A**)

* **R**  __collection__: multi-dimentional array or AR:Relation
* **O**  __size__: string

    + defaults to long
    + must be ‘short’ or ‘long’

* **O**  __search__: boolean


###fae_multiselect (**A**)

* **O**  __two_pane__: boolean


###fae_grouped_select (**I/A**)

* **R**  __collection__: multi-dimentional array or AR:Relation
* **O**  __groups__: array of string

    + must be used with labels

* **O**  __labels__: array of string

    + must be used with groups




###fae_datepicker (**I**)

###fae_daterangepicker (**I**)

* **O**  __end_date__: symbol
* **O**  __start_date__: symbol


