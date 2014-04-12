--local k,l,_=pcall(require,\"luarocks.loader\") _=k and l.add_context(\"busted\",\"1.10.0-1\")

describe("Basic functional programming facilities", function()
  local functional
  
  setup(function()
    functional = require('functional')
  end)

  teardown(function()
  end)
  
  describe("Map facility", function() 
    it("map on empty table shall return empty table", function()
      assert.are.same(functional.map({}, function(x) end), {})
    end)
  
    it("map null function on table shall return empty table", function()
      assert.are.same(functional.map({1,2,3,4,5}, function(x) end), {})
    end)
  
    it("map function on table shall return table with all elements modified", function()
      assert.are.same(functional.map({1,2,3,4,5}, function(x) return x*10 end), {10, 20, 30, 40, 50})
    end)

    it("map function on table shall preserve indices", function()
      assert.are.same(functional.map({['bob'] = 3,['alice'] = 4, [4] = 5}, function(x) return 2 * x + 20 end), {['bob'] = 26, ['alice'] = 28, [4] = 30})
    end)

    it("map function can be used with tables", function()
      assert.are.same(functional.map({{1,2,3}, {2,3,4}, {3,4,5}}, function(x) return x[1] end), {1,2,3})
    end)

    it("map function can be used with strings", function()
      assert.are.same(functional.map({"a", "b", "v"}, function(x) return x .. "!" end), {"a!", "b!", "v!"})
    end)
  end)
  
  describe("Partitioning facility", function() 
    it("if all elements satisfy predicate second table is empty", function() 
      local right, wrong = functional.partition({1,2,3,4,5}, function() return true end)
      assert.are.same({1,2,3,4,5}, right)
      assert.are.same({}, wrong)
    end)
    it("if no elements satisfy predicate first table is empty", function() 
      local right, wrong = functional.partition({1,2,3,4,5}, function() return false end)
      assert.are.same({}, right)    
      assert.are.same({1,2,3,4,5}, wrong)
    end)
    it("elements satisfying predicate to go first table, others to the second", function() 
      local right, wrong = functional.partition({1,2,3,4,5}, function(x) return x > 3 end)
      assert.are.same({[4] = 4,[5] = 5}, right)
      assert.are.same({1,2,3}, wrong)    
    end)
    it("keys are preserved during partitioning", function() 
      local right, wrong = functional.partition({['a'] = 1, ['b'] = 2, ['alice'] = 3, [8] = 4, ['bar'] = 5}, function(x) return x < 3 end)
      assert.are.same({['a'] = 1,['b'] = 2}, right)
      assert.are.same({['alice'] = 3, [8] = 4, ['bar'] = 5}, wrong)    
    end)    
  end)
  
  describe("Filter facility", function()
    it("filter on empty table shall return empty table", function()
      assert.are.same(functional.filter({}, function(x) end), {})
    end)  

    it("filter shall return equal table if all elements fulfill predicate", function()
      assert.are.same(functional.filter({1,2,3}, function(x) return true end), {1,2,3})
    end)  
 
    it("filter shall return empty table if no elements fulfill predicate", function()
      assert.are.same(functional.filter({1,2,3}, function(x) return false end), {})
    end)  

    it("filter shall return table with elements fulfilling predicate", function()
      assert.are.same(functional.filter({1,2,3,4}, function(x) return x>2 end), {[3] = 3,[4] = 4})
    end)  

    it("filter shall preserve indices", function()
      assert.are.same(functional.filter({['bob'] = 1, ['alice'] = 2, [100] = 3}, function(x) return x <= 2 end), {['bob'] = 1, ['alice'] = 2})
    end)
    
    it("filter shall work with tables", function()
      assert.are.same(functional.filter({{}, {1,2}, {1,2,3}, {1,2,3,4}}, function(x) return #x < 3 end), {{}, {1,2}})
    end)
    
    it("filter shall work with strings", function()
      assert.are.same(functional.filter({'a', 'ala', 'alice'}, function(x) return x .. 'la' == 'ala' end), {'a'})
    end)
  end)
  
  describe("First facility", function()
    it("first shall return nil if no element satisfies predicate", function() 
      assert.is_true(functional.first({1,2,3}, function(x) return false end) == nil)
    end)  
    it("first shall index of first element satisfying predicate", function()
      assert.is_true(functional.first({1,2,3}, function(x) return true end) == 1)
    end)  
    it("first shall index of any element satisfying predicate in associative array", function() 
      local index = functional.first({['a'] = 1,['b'] = 2,['c'] = 3}, function(x) return x > 1 end)
      assert.is_true(index == 'c' or index == 'b')
    end)
  end)
  
  describe("All facility", function()
    it("all shall return true for empty table", function()
      assert.is_true(functional.all({}, function(x) return false end))
    end)
    
    it("all shall return false if table contains an element not fulfilling predicate", function()
      assert.is_false(functional.all({1}, function(x) return false end))
    end)

    it("all shall return true if table contains only elements fulfilling predicate", function()
      assert.is_true(functional.all({1, 2}, function(x) return x ~= 0 end))
    end)
    
    it("all shall return false if table contains at least one element not fulfilling predicate", function()
      assert.is_false(functional.all({1, 2, 4, 6, 7, 0}, function(x) return x ~= 0 end))
    end)
    
    it("all shall work with tables", function()
      assert.is_true(functional.all({{1, 2}, {1}}, function(x) return #x ~= 0 end))
    end)
    
    it("all shall work with strings", function()
      assert.is_true(functional.all({'a', 'b'}, function(x) return x ~= 'c' end))
    end)    
  end)
  
  describe("Any facility", function()
    it("any shall return false for empty table", function()
      assert.is_false(functional.any({}, function(x) return false end))
    end)
    
    it("any shall return false if table contains only elements not fulfilling predicate", function()
      assert.is_false(functional.any({1}, function(x) return false end))
    end)

    it("any shall return true if table contains only elements fulfilling predicate", function()
      assert.is_true(functional.any({1, 2}, function(x) return x ~= 0 end))
    end)
    
    it("any shall return false if table contains only elements not fulfilling predicate", function()
      assert.is_false(functional.any({1, 2}, function(x) return x == 0 end))
    end)
    
    it("any shall return true if table contains at least one element fulfilling predicate", function()
      assert.is_true(functional.any({1, 2, 4, 6, 7, 0}, function(x) return x == 0 end))
    end)
    
    it("any shall work with tables", function()
      assert.is_true(functional.any({{1, 2}, {1}}, function(x) return #x == 2 end))
    end)
    
    it("any shall work with strings", function()
      assert.is_true(functional.any({'a', 'b'}, function(x) return x == 'b' end))
    end)    
  end)
  
  describe("empty facility", function() 
    it("empty table is empty", function() 
      assert.is_true(functional.empty({}))
      assert.is_true(functional.empty({nil}))
    end) 
    it("nonempty table is not empty", function() 
      assert.is_false(functional.empty({2}))
      assert.is_false(functional.empty({2.2,3}))
      assert.is_false(functional.empty({1232.123}))
      assert.is_false(functional.empty({'sasa'}))
      assert.is_false(functional.empty({{}}))
      assert.is_false(functional.empty({function() end}))
      assert.is_false(functional.empty({{},{}}))
      assert.is_false(functional.empty({{},'a',222}))
      assert.is_false(functional.empty({true}))
      assert.is_false(functional.empty({false}))
    end)
  end)
  
  describe("zip_with facility", function()
    it("zip_with shall return table of sums if sum is the function", function() 
      assert.are.same({2,5,10}, functional.zip_with(functional.sum, {1,2,5}, {1,3,5}))
    end)
    it("zip_with shall return table of concatenated strings if concatenation is the function", function() 
      assert.are.same({'11bob','23alice','55john'}, functional.zip_with(functional.concatenate, {1,2,5}, {1,3,5}, {'bob', 'alice', 'john'}))
    end)
  end)
  
  describe("Zip facility", function() 
    it("zip on nothing shall return nil", function()
      assert.is_true(functional.zip() == nil)    
    end)
    it("zip on one table shall return one - element tables with its values", function()
      assert.are.same(functional.zip({1,2}), {{1}, {2}})    
    end)
    it("zip shall join tables by keys", function()
      assert.are.same(functional.zip({1,2}, {4,5}, {100, 200}), {{1, 4, 100}, {2, 5, 200}})    
    end)
    it("zip shall join tables by keys, empty elements shall be nil", function()
      assert.are.same(functional.zip({1,2,3,10}, {4,5,12}, {100, 200}, {1000}), {{1, 4, 100, 1000}, {2, 5, 200}, {3, 12}, {10}})    
    end)
    it("zip shall join tables by keys and work even with string indices", function()
      assert.are.same(functional.zip({['a'] = 1, ['bob'] = 2,3}, {4,5,['bob'] = 12}, {['a'] = 100, 200}), 
        {[1] = {3, 4, 200}, [2] = {[2] = 5}, ['a']={[1] = 1, [3] = 100}, ['bob'] = {[1] = 2, [2] = 12}})    
    end)
    it("zip shall also work with strings", function()
      assert.are.same(functional.zip({'a', 'b'}, {'l', 'o'}, {'i', 'b'}, {'c'}, {'e'}),{{'a', 'l', 'i', 'c', 'e'}, {'b', 'o', 'b'}})    
    end)
    it("zip shall also work with inner tables and mixed types", function()
      assert.are.same(functional.zip({{'a'}, {}}, {1, 'b'}, {'i', 0}, {{'c'}, {'b'}}, {'e'}),{{{'a'}, 1, 'i', {'c'}, 'e'}, {{}, 'b', 0, {'b'}}})    
    end)
  end)
  
  describe("Fold facility", function()
    it("fold on empty table shall return starting accumulator", function()
      assert.are.equal(1, functional.fold({}, function(acc, x) return acc * x end, 1))
    end)    
    it("fold with muliplying calculates product of a table", function()
      assert.are.equal(120, functional.fold({1,2,3,4,5}, function(acc, x) return acc * x end, 1))
    end)    
    it("fold with sum calculates sum of a table", function()
      assert.are.equal(15, functional.fold({1,2,3,4,5}, function(acc, x) return acc + x end, 0))
    end)
    it("fold with sum calculates sum of a table and starting accumulator", function()
      assert.are.equal(115, functional.fold({1,2,3,4,5}, function(acc, x) return acc + x end, 100))
    end)
    it("fold with inserting creates a table with given indices", function()
      assert.are.same({1,2,3,4,5}, functional.fold({1,2,3,4,5}, function(acc, x) acc[x] = x; return acc end, {}))
    end)
    it("fold with concatenation merges strings", function()
      assert.are.same('bob and alice', functional.fold({'bo', 'b ', 'and', ' al', 'ice'}, function(acc, x) return acc .. x end, ''))
    end)
  end)
  
  describe("Forall faciity", function()
    it("If every element is a table one may add an element to them", function() 
      local tab = {{}, {2, 3}, {'a'}}
      functional.forall(tab, function(x) x[#x + 1] = '4' end)
      assert.are.same({'4'}, tab[1])
      assert.are.same({2, 3, '4'}, tab[2])
      assert.are.same({'a', '4'}, tab[3])
    end)
  end)
  
  describe("Head and tail facilities", function() 
    it("head returns first element of a sequence, tail returns rest of them", function() 
      local tab = {1,2,3}
      assert.equal(1, functional.head(tab))
      assert.are.same({[2] = 2, [3] = 3}, functional.tail(tab))
    end)
    it("head returns first element of a sequence, tail returns rest of them, works for multiple same values", function() 
      local tab = {1,2,3,1}
      assert.equal(1, functional.head(tab))
      assert.are.same({[2] = 2, [3] = 3, [4] = 1}, functional.tail(tab))
    end)
  end)
  
  describe("Sum facility", function()
    it("sum of empty table is 0", function()
      assert.are.equal(0, functional.sum({}))  
    end)
    it("sum of table is sum of its elements", function()
      assert.are.equal(100, functional.sum({10, 20, 30, 40}))  
    end)
  end)
  
  describe("Product facility", function()
    it("product of empty table is 1", function()
      assert.are.equal(1, functional.product({}))  
    end)
    it("product of table is product of its elements", function()
      assert.are.equal(100, functional.product({10, 2, 5}))  
    end)
  end)
  
  describe("Concatenate facility", function()
    it("concatenation of empty table is empty string", function()
      assert.are.equal('', functional.concatenate({}))  
    end)
    it("concatenation of table is its elements concatenated", function()
      assert.are.equal('alice and bob eat fruit', functional.concatenate({'alice ', 'and ', 'bob', ' ea', 't fr', 'uit'}))  
    end)
  end)

  describe("Maximum facility", function()
    it("maximum of table is biggest value in table", function()
      assert.are.equal(1000, functional.maximum({1000, 1,210,310}))  
    end)
    it("maximum of table is biggest value in associative table", function()
      assert.are.equal(1000, functional.maximum({['a'] = 1000, [function() end] = 1, [{}] = 210, ['aaa'] = 310}))  
    end)
  end)

  describe("Minimum facility", function()
    it("minimum of table is smallest value in table", function()
      assert.are.equal(-10, functional.minimum({1,10,-10, 200}))
    end)
    it("minimum of table is smallest value in associative table", function()
      assert.are.equal(1, functional.minimum({['a'] = 1000, [function() end] = 1, [{}] = 210, ['aaa'] = 310}))  
    end)
  end)
  
  describe("Scan facility", function()
    it("Scan over empty table returns table containing only accumulator", function()
      assert.are.same({2}, functional.scan({}, function(x) return nil end, 2))  
    end)
    it("Scan over table returns table with all intermediate values", function()
      assert.are.same({2, 2, 2, 2}, functional.scan({1,2,3}, function(x, y) return 2 end, 2))  
    end)
    it("Scan over table returns table with all intermediate accumulator results", function()
      assert.are.same({2, 3, 5, 8}, functional.scan({1,2,3}, function(x, y) return x + y end, 2))  
    end)
    it("Scan over table works also with tables", function()
      assert.are.same({0, 1, 4, 5}, functional.scan({{1}, {{}, 'a', 2}, {{}}}, function(x, y) return x + #y end, 0))  
    end)
    it("Scan over table works also with strings", function()
      assert.are.same({'', 'a', 'ali', 'alice'}, functional.scan({'a', 'li', 'ce'}, function(x, y) return x .. y end, ""))  
    end)
  end)
  
  describe("Compose facility", function() 
    it("Compose square and sum returns square of sum", function() 
      local square = function(x) return x * x end
      local sum = function(x, y) return x + y end
      local composed = functional.compose(square, sum)
      
      for i=0,10 do
        assert.equal(square(sum(i, 10*i)), composed(i, 10*i))
      end          
    end)
    
    it("Compose concatenate and repeat twice returns twice concatenated string", function() 
      local repeat_twice = function(x) return x .. x end
      local concatenate = function(...) return functional.fold({...}, function(acc, x) return acc .. x end, '') end
      local composed = functional.compose(repeat_twice, concatenate)
      assert.equal(repeat_twice(concatenate('a', 'l', 'i', 'c', 'e')), composed('a', 'l', 'i', 'c', 'e'))
    end)
  end)

  describe("Flip facility", function()
    it("flip on subtraction shall have operands swapped", function() 
      local sub = function(x, y) return x - y end
      for i = 0, 10 do
        assert.equal(sub(i, i + 10), functional.flip(sub)(i + 10, i))
      end
    end)    
    it("flip on concatenation shall concatenate in reverse order", function() 
      assert.equal('ecila', functional.fold({'a', 'l', 'i', 'c', 'e'}, functional.flip(function(x, y) return x .. y end), ''))
    end)
  end)
  
  describe("Flipall facility", function()
    it("Five arguments may be flipped", function()
      local decimal = function(a1, a2, a3, a4, a5) return a1 + 10*a2 + 100*a3 + 1000*a4 + 10000*a5 end
      local flipped = functional.flipall(decimal, {3, 5, 2, 1, 4})
      assert.equal(decimal(1,2,3,4,5), flipped(3, 5, 2, 1, 4))
    end)
    it("Three arguments may be flipped", function()
      local concat = function(a1, a2, a3) return a1 .. a2 .. a3 end
      local flipped = functional.flipall(concat, {3, 1, 2})
      assert.equal(concat("alice", "and", "bob"), flipped("bob", "alice", "and"))
    end) 
  end)
  
  describe("Extract args facility", function()
    it("Five arguments can be extracted", function() 
      local tab = {1,2,nil,4,5}
      a1,a2,a3,a4,a5 = functional.extract_args(5, tab)
      
      assert.equal(1, a1)
      assert.equal(2, a2)
      assert.equal(nil, a3)
      assert.equal(4, a4)
      assert.equal(5, a5)
    end)  
  end)
  
  describe("Contains facility", function()
    it("empty table shall contain nothing", function()
      assert.is_false(functional.contains({}, ''))
    end)
    it("table with two values contains only these two values", function()
      local tab = {1,2}
      assert.is_false(functional.contains(tab, ''))
      assert.is_false(functional.contains(tab, 100))
      assert.is_false(functional.contains(tab, {}))
      assert.is_false(functional.contains(tab, nil))
      assert.is_true(functional.contains(tab, 1))
      assert.is_true(functional.contains(tab, 2))
    end)
    it("contains works also with functions, strings and tables, but only named ones", function()
      local f = function() end
      local t = {}
      local tab = {t, f, 'a', 2, 2.22}
      assert.is_false(functional.contains(tab, 'bb'))
      assert.is_false(functional.contains(tab, {}))
      assert.is_false(functional.contains(tab, function() end))
      assert.is_false(functional.contains(tab, {2}))
      assert.is_false(functional.contains(tab, function(x) return x*2 end))
      assert.is_false(functional.contains(tab, 2131))
      assert.is_true(functional.contains(tab, t))
      assert.is_true(functional.contains(tab, f))
      assert.is_true(functional.contains(tab, 2))
      assert.is_true(functional.contains(tab, 2.22))
    end)
  end)
  
  describe("Value equality facility", function()
    it("empty tables have equal values", function()
      assert.is_true(functional.are_values_equal({}, {}))
    end)
    it("same table has equal values values", function()
      tab = {1,2,3,4}
      assert.is_true(functional.are_values_equal(tab, tab))  
    end)
    it("equal tables have equal values", function()
      assert.is_true(functional.are_values_equal({1,2,3,4}, {1,2,3,4}))  
    end)
    it("keys do not matter in value equality", function()
      assert.is_true(functional.are_values_equal({1,2,3,4}, {4,3,2,1}))    
    end)
    it("tables with different sizes have different values", function()
      assert.is_false(functional.are_values_equal({1,1,2,3,4}, {4,3,2,1}))    
    end)
    it("tables with different values have different values", function()
      assert.is_false(functional.are_values_equal({1,1,2,4}, {4,3,2,1}))    
    end)
  end)
  
  describe("Keys facility", function() 
    it("keys of an array are consecutive integers", function()
      assert.is_true(functional.are_values_equal({1,2,3,4,5}, functional.keys({10, 213.1,function() end,'ala',{}})))
    end)
  
    it("keys of associative array are extracted properly", function()
      assert.is_true(functional.are_values_equal({'ala', 'kota', 'ma', 1, 2}, functional.keys{['ala'] = true, ['kota'] = '1212', ['ma'] = 1231231, [1] = function() end, [2] = {}}))
    end)
    
    it("keys of associative array are extracted properly", function()
      assert.is_true(functional.are_values_equal({'ala', 'kota', 'ma', 1, 2}, functional.keys{['ala'] = true, ['kota'] = '1212', ['ma'] = 1231231, [1] = function() end, [2] = {}, [3] = nil}))
    end)
  end)
  
  describe("Values facility", function()
    it("values of an array are extracted properly", function() 
      assert.is_true(functional.are_values_equal(functional.values({1,2,3,4}), {1,2,3,4}))
    end)
    it("values of an associative table are extracted properly", function() 
      assert.is_true(functional.are_values_equal({1,2,3,4}, functional.values({['l'] = 1,[0] = 2,['bob'] = 3,4})))
    end)
  end)
  
  describe("Key sensitive flatten", function()
    it("keys are preserved during flattening", function() 
      assert.are.same({[1] = 1, [2] = 2, ['bob'] = 'kle'}, functional.key_sensitive_flatten({{1,2}, {['bob'] = 'kle'}}))
    end)
    it("value of last table overrides previous", function() 
      assert.are.same({[1] = 10, [2] = 2, ['bob'] = 'kle'}, functional.key_sensitive_flatten({{1,2}, {10, ['bob'] = 'kle'}}))
    end)
  end)
 
  describe("Key insensitive flatten", function()
    it("keys are not preserved during flattning", function() 
      assert.is_true(functional.are_values_equal({1,2,3,4,5,6,1,2,3,4}, functional.key_insensitive_flatten({{1,2,3}, {1,2,3,4}, {4,5,6}})))
    end)
    it("different number of occurrences matters", function() 
      local f = function() end
      assert.is_true(functional.are_values_equal({1,2,3,4,5,'bob', 'bob',f,6,4,1,1,1}, functional.key_insensitive_flatten({{1,2,1}, {1,3,4, 'bob'}, {4,5,1,6}, {f,'bob'}})))
    end)
  end)
  
  describe("Currying facility", function()
    it("five-arg function can be called four times before evaluating if curried", function() 
      local curried = functional.curry(function(a,b,c,d,e) return a+b+c+d+e end, 5)
      local curried_four_times = curried(1)(1)(5)(1)
      assert.equal(9, curried_four_times(1))
    end)
    it("curried function becomes a vararg", function() 
      local curried = functional.curry(function(a,b,c,d,e) return a+b+c+d+e end, 5)
      local curried_three_times = curried(5)(1,6)
      assert.equal(16, curried_three_times(2,2))
    end)
    it("currying is fun!", function() 
      local curried = functional.curry(function(a,b,c) return a .. b .. c end, 3)
      local curried_twice = curried(1,2)
      assert.equal('122', curried_twice(2,2))
    end)
    it("additional arguments get discarded", function() 
      local curried = functional.curry(function(a,b,c) return a .. b .. c end, 5)
      local curried_three_times = curried(1,2,5)
      assert.equal('125', curried_three_times(2,2))
    end)
    it("varargs also can be curried", function() 
      local curried = functional.curry(functional.zip, 3)
      local once_called = curried({1,2,3})
      assert.are_same({{1,1,1}, {2,2,2}, {3,3,3}}, once_called({1,2,3}, {1,2,3}))
    end)
  end)
  
  describe("call_until facility", function() 
    it("call_until returns first value satisfying predicate", function() 
      assert.equal(10, functional.call_until(function(x) return x > 9 end, function(x) return x + 2 end, 2))
    end)
    it("call_until returns start value if it satisfies predicate", function() 
      assert.equal(2, functional.call_until(function(x) return x < 10 end, function(x) return x + 2 end, 2))
    end)
  end)
  
  describe("times facility", function()
    it("0 times anything is empty table", function() 
      assert.are.same({}, functional.times(0, {}))
    end)
    it("2 times empty table is table with two empty tables", function() 
      assert.are.same({{},{}}, functional.times(2, {}))
    end)
    it("5 times 1 is table with five ones", function()
      assert.are.same({1,1,1,1,1}, functional.times(5, 1))
    end)
  end)
  
  describe("take facility", function()
    it("if one element is taken first one is returned", function()
      assert.are.same({1}, functional.take(1, function() return 1 end))
    end)
    it("if three elements are taken first three are returned", function()
      local i = 0
      assert.are.same({1,2,3}, functional.take(3, function() i = i+1; return i end))
    end)
    it("if five elements are taken first five are returned", function()
      local i = ''
      assert.are.same({'a', 'aa', 'aaa', 'aaaa', 'aaaaa'}, functional.take(5, function() i = i .. 'a'; return i end))
    end)
  end)
  
  describe("drop facility", function()
    it("if one element is taken iterator holds second one", function()
      assert.equal(1, functional.drop(1, function() return 1 end)())
    end)
    it("if three elements are taken iterator holds fourth", function()
      local i = 0
      assert.equal(4, functional.drop(3, function() i = i+1; return i end)())
    end)
    it("if five elements are taken first five are returned", function()
      local i = ''
      assert.equal('aaaaaa', functional.drop(5, function() i = i .. 'a'; return i end)())
    end)
  end)
  
  describe("range facility", function() 
    it("5 elements stepping from 0 by 2 is 0, 2,4,6,8", function()
      assert.are.same({0,2,4,6,8}, functional.range(5, 0, 2))
    end)
    it("5 elements stepping from 0 by -2 is 0, -2,-4,-6,-8", function()
      assert.are.same({0,-2,-4,-6,-8}, functional.range(5, 0, -2))
    end)
  end)
  
  describe("is_sequence facility", function()
    it("empty table is a sequence", function()
      assert.is_true(functional.is_sequence({}))
    end)
    it("nonempty sequential table is a sequence", function()
      assert.is_true(functional.is_sequence({1,2,3,4,5,6,100}))
    end)
    it("associative table is not a sequence", function()
      assert.is_false(functional.is_sequence({[{}] = 1, [function() end] = 2, [4] = 2, 1,2,3}))
    end)
  end)
  
  describe("cycle facility", function() 
    it("six first elements from cycle made out of two elements", function() 
      assert.are.same({1,2,1,2,1,2}, functional.take(6, functional.cycle(1,2)))
    end)
    it("six first elements from cycle made out of five elements", function() 
      assert.are.same({1,2,3,4,100,1}, functional.take(6, functional.cycle(1,2,3,4,100)))
    end)
  end)
  
end)