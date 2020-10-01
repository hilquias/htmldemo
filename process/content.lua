local section_counter = { 0, 0 }

local example_counter = 0

local function make_preview_href (section, example)
   local href = table.concat {
      "examples/", table.concat (section, "-"), "-example-", example, ".html"
   }

   return href
end

local function make_preview_link (section, example)
   local href = make_preview_href (section, example)

   local title = table.concat {
      "Section ", table.concat (section, "."), ", example ", example, "."
   }

   local link = pandoc.Link ("Try it!", href, title, { target = "preview" })

   return pandoc.Para { link }
end

local function make_preview_file (section, example, code)
   local filename = make_preview_href (section, example)

   code = string.gsub(code, 'https://example.com', 'images')

   code = string.gsub(code, '[-a-zA-Z0-9/_]+.jpe?g', 'placeholder.png')
   code = string.gsub(code, '[-a-zA-Z0-9/_]+.png', 'placeholder.png')
   code = string.gsub(code, '[-a-zA-Z0-9/_]+.cgi', 'placeholder.png')
   code = string.gsub(code, '[-a-zA-Z0-9/_]+.svg', 'placeholder.png')
   code = string.gsub(code, '[-a-zA-Z0-9/_]+.ogv', 'placeholder.ogv')
   code = string.gsub(code, '[-a-zA-Z0-9/_]+.mov', 'placeholder.ogv')
   code = string.gsub(code, '[-a-zA-Z0-9/_]+.css', 'placeholder.css')
   code = string.gsub(code, '[-a-zA-Z0-9/_]+.js', 'placeholder.js')

   code = '<link rel="stylesheet" href="/preview.css">\n' .. code

   local f = io.open (filename, 'w')
   f:write (code)
   f:close ()
end

function Header (el)
   if el.level <= 2 then
      section_counter[el.level] = section_counter[el.level] + 1

      for k = el.level + 1, #section_counter do
	 section_counter[k] = 0
      end

      example_counter = 0
   end
end

function CodeBlock (el)
   local out = {}

   example_counter = example_counter + 1
   
   make_preview_file (section_counter, example_counter, el.text)

   local link = make_preview_link (section_counter, example_counter)

   table.insert (out, el)
   table.insert (out, link)

   return out
end
