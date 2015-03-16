# expose uniqueness attributes in Judge in here with the following syntax
#
# Judge.config.exposed[ModelName] = [:attribute]
#
# add one line for each unique attribue
# passing these through as one block won't work due to autoloading in development
# see: https://github.com/joecorcoran/judge/issues/24#issuecomment-64962861
#
# example:
# Judge.config.exposed[Person]  = [:slug]
# Judge.config.exposed[Wine]    = [:name]
# Judge.config.exposed[Wine]    = [:slug]
