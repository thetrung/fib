local function fib_tail (n, a, b)
    if n == 0 then return a 
    else if n == 1 then return b
    else return fib_tail(n - 1, b, a + b) end
    end
end

print (fib_tail(90, 0, 1))