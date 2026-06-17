-- Tiny assertion harness.
--
-- plenary.nvim is installed, but its busted runner needs a minimal_init that
-- rebuilds runtimepath; these tests only load plain config tables and the
-- builtin filetype matcher, so a ~30-line harness run under `nvim -l` keeps the
-- whole suite dependency-free and runnable straight from the repo root.

local H = { passed = 0, failed = 0, failures = {} }

-- Each case is isolated in pcall so one failing assertion reports and the rest
-- still run -- a thrown error should not abort the whole suite.
function H.test(name, fn)
    local ok, err = pcall(fn)
    if ok then
        H.passed = H.passed + 1
    else
        H.failed = H.failed + 1
        table.insert(H.failures, name .. ": " .. tostring(err))
    end
end

function H.eq(actual, expected, msg)
    if actual ~= expected then
        error(
            (msg or "values differ") .. " (expected " .. vim.inspect(expected) .. ", got " .. vim.inspect(actual) .. ")",
            2
        )
    end
end

function H.is_true(cond, msg)
    if not cond then
        error(msg or "expected truthy value", 2)
    end
end

-- List membership check, used heavily for filetypes/ensure_installed arrays.
function H.contains(list, value, msg)
    for _, v in ipairs(list or {}) do
        if v == value then
            return
        end
    end
    error((msg or "missing value") .. ": " .. vim.inspect(value) .. " not in " .. vim.inspect(list), 2)
end

-- Resolve a path relative to the repo root. ROOT is derived from the runner's
-- own location (see run.lua), so specs never hardcode an absolute path that
-- would break on another machine or when run from a different directory.
function H.path(rel)
    return H.ROOT .. "/" .. rel
end

-- lazy.nvim plugin files return either a single spec table or a list of them.
-- Specs key the plugin name at index [1]; this finds the spec whose [1] matches
-- so a test can assert on one plugin regardless of file layout.
function H.find_spec(loaded, name)
    local specs = type(loaded[1]) == "string" and { loaded } or loaded
    for _, spec in ipairs(specs) do
        if spec[1] == name then
            return spec
        end
    end
    return nil
end

function H.report()
    print(string.format("\n%d passed, %d failed", H.passed, H.failed))
    for _, f in ipairs(H.failures) do
        print("  FAIL " .. f)
    end
    return H.failed == 0
end

return H
