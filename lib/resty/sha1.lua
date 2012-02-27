module("resty.sha1", package.seeall)


local ffi = require "ffi"
local ffi_new = ffi.new
local ffi_str = ffi.string
local C = ffi.C

local mt = { __index = resty.sha1 }


ffi.cdef[[
typedef unsigned long SHA_LONG;

enum {
    SHA_LBLOCK = 16
};

typedef struct SHAstate_st
        {
        SHA_LONG h0,h1,h2,h3,h4;
        SHA_LONG Nl,Nh;
        SHA_LONG data[SHA_LBLOCK];
        unsigned int num;
        } SHA_CTX;

int SHA1_Init(SHA_CTX *c);
int SHA1_Update(SHA_CTX *c, const void *data, size_t len);
int SHA1_Final(unsigned char *md, SHA_CTX *c);
]]

local buf = ffi_new("char[20]")


function new(self)
    local ctx = ffi_new("SHA_CTX[1]")
    if C.SHA1_Init(ctx) == 0 then
        return nil
    end

    return setmetatable({ _ctx = ctx }, mt)
end


function update(self, s)
    return C.SHA1_Update(self._ctx, s, #s) == 1
end


function final(self)
    if C.SHA1_Final(buf, self._ctx) == 1 then
        return ffi_str(buf, 20)
    end

    return nil
end


function reset(self)
    return C.SHA1_Init(self._ctx) == 1
end


-- to prevent use of casual module global variables
getmetatable(resty.sha1).__newindex = function (table, key, val)
    error('attempt to write to undeclared variable "' .. key .. '": '
            .. debug.traceback())
end
