-- ===================================================================

local stringify = pandoc.utils.stringify

local wrap, yield = coroutine.wrap, coroutine.yield

-- ===================================================================

local function is_source_block (block)
   if block.t == 'Header' then
      return true
   end
   if block.t == 'Div' and block.classes[1] == 'example' then
      return true
   end
   return false
end

local function source_blocks (blocks)
   for _, block in pairs (blocks) do
      if is_source_block (block) then
	 yield (block)
      end
   end
end

local function section_has_demos (header)
   if header.level == 3 then
      return true
   end
   if string.find (stringify (header), 'The .+ elements?') then
      return true
   end
   if string.find (stringify (header), 'States of the type attribute') then
      return true
   end
   if string.find (stringify (header), '%w+ state %(type=%w+%)') then
      return true
   end
   if string.find (stringify (header), 'The %w+ attribute?') then
      return true
   end
   return false
end

local function demo_section_blocks (blocks)
   local include = false

   local function it (blocks)
      return wrap (function ()
	    source_blocks (blocks)
      end)
   end

   for block in it (blocks) do
      if block.t == 'Header' then
	 include = section_has_demos (block)
      end
      if block.t == 'Header' then      
	 block.level = block.level - 2
      end
      if include then
	 yield (block)
      end
   end
end

function Pandoc (doc)
   local out = {}

   local function it (blocks)
      return wrap (function ()
	    demo_section_blocks (blocks)
      end)
   end

   for el in it (doc.blocks) do
      table.insert (out, el)
   end

   return pandoc.Pandoc (out, doc.meta)
end

-- ===================================================================

function CodeBlock(el)
   -- for syntax highlight
   el.classes = { 'html' }
   -- clean up
   return { el }
end

-- ===================================================================

function Div(el)
   if el.classes[1] == 'example' then
      -- clean up
      return pandoc.Div (el.content, pandoc.Attr (nil, { 'example' }))
   else
      -- clean up
      return pandoc.Div (el.content)
   end
end

-- ===================================================================

function Header (el)
   local out = {}

   for i, content in pairs (el.content) do
      if i ~= 1 or content.t ~= 'Space' then
	 table.insert (out, content)
      end
   end

   return pandoc.Header (el.level, out)
end

-- ===================================================================

function Code (el)
   return pandoc.Code (el.text)	-- clean up
end

-- ===================================================================

function Image (el)
   -- clean up
   local src = string.gsub (el.src, '^/images', 'images')
   -- clean up
   return pandoc.Image (el.caption, src, el.title, el.attr)
end

-- ===================================================================

function Link (el)
   return pandoc.Strong (el.content) -- clean up
end

-- ===================================================================

function Span (el)
   if el.classes[1] == 'secno' then return {} end -- ignore
end

-- ===================================================================
