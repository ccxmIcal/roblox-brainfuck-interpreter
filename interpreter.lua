local tape: { number } = {}; -- Initializing the memory
local ptr: number = 1; -- Memory pointer
local outputbuffer: string = "";
local codeindex: number = 1;

local function init(): nil
	tape = {};
	ptr = 1;
	codeindex = 1;
	outputbuffer = "";
	for i: number = 1, 30000 do
		tape[i] = 0; -- initialize the memory with 30k cells
	end
end

local function checkcode(code: string): boolean
	local pattern: string = "[><%+%-.,%[%]]*";
	return code:match(pattern) == code;
end

script.Parent.input.InputBegan:Connect(function(inputObject: InputObject)
	if inputObject.UserInputType == Enum.UserInputType.Keyboard then
		local start: number = tick();
		warn("Began");
		init();
		local codelength: number = #script.Parent.input.Text;
		local inputText: string = script.Parent.input.Text;
		if not checkcode(inputText) then
			error("Invalid Brainfuck code");
			return;
		end
		while codeindex <= codelength do
			local command: string = string.sub(inputText, codeindex, codeindex);
			if command == ">" then
				ptr += 1; -- Move the memory pointer to the right
			elseif command == "<" then
				ptr -= 1; -- Move the memory pointer to the left
			elseif command == "+" then
				tape[ptr] = (tape[ptr] + 1) % 256 -- Increment the value at the current memory cell
			elseif command == "-" then
				tape[ptr] = (tape[ptr] - 1) % 256 -- Decrement the value at the current memory cell
			elseif command == "." then
				outputbuffer = outputbuffer .. string.char(tape[ptr]) -- Add the character at the current memory cell
			elseif command == "," then
				-- We cannot really input in Roblox Lua
			elseif command == "[" then
				-- this one is annoying. if the current memory cell is 0, skip to the matching ]
				if tape[ptr] == 0 then  -- If the current memory cell is 0, start skipping to the matching ']'
					local level: number = 1;  -- Initialize the loop nesting level to 1
					while level > 0 do        -- Continue until the level is 0, indicating a matched pair
						codeindex += 1;       -- Move forward one character in the Brainfuck code
						if codeindex > codelength then  
							error("Unmatched '['");  -- If we've reached the end of the code, it's an unmatched '['
						end
						local c: string = string.sub(inputText, codeindex, codeindex);  -- Get the character at the current position
						if c == "[" then
							level += 1;       -- Increase the nesting level (indicating an unmatched pair)
						elseif c == "]" then
							level -= 1;       -- Decrease the nesting level (indicating a matched pair)
						end
					end
				end

			elseif command == "]" then
				-- If the current memory cell is not 0, then skip to the matching [
				if tape[ptr] ~= 0 then
					local level: number = 1;  -- Initialize the loop nesting level to 1
					while level > 0 do        -- Continue until the level is 0, indicating a matched pair
						codeindex -= 1;        -- Move back one character in the Brainfuck code
						if codeindex < 1 then 
							error("Unmatched ']'");  -- If we've reached the beginning of the code, it's an unmatched ']'
						end
						local c: string = string.sub(inputText, codeindex, codeindex);  -- Get the character at the current position
						if c == "[" then
							level -= 1;       -- Decrease the nesting level (indicating a matched pair)
						elseif c == "]" then
							level += 1;       -- Increase the nesting level (indicating an unmatched pair)
						end
					end
				end
			end
			codeindex += 1; -- Increment codeindex inside the loop
		end
		print(string.format("BF Output: %s", outputbuffer));
		warn(string.format("Code interpreted in: %s seconds.", tick() - start));
	end
end)
