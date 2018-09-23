--pretty = require 'pl.pretty'
--log = require 'log'


INITIAL_NUM_RETRIES = 5

--shim = function (...) print(...) end

--log = {"info" = shim,"warn" = shim,"error" = shim}


function RequestQueue ()

  local BUSY = false
  queue = {}

  function queue:processAt (position)

    if BUSY or position > table.maxn(self) then
      return nil
    else
      msg = self[position]
    end

    if msg.data and not msg.headers then
      -- The choice of "data" for the headers was a bad choice.
      -- But some code uses that, so for backwards compatibility,
      -- both "data" and "headers" can be used to set the headers
      msg.headers = msg.data
    end

    -- the actual handler callback passed to the http module, it wraps the callback
    -- specified in the message, only calling it when the message is successful
    function handler (code, data)
      BUSY = false
      if code == 200 then
        msg.callback(code, data)
        --log.info(msg.url, code)
        msg.numRetries = 0  -- it will be removed after this pass through
      else
        --print("***** REQUEST FAILURE *****")
        --print("code: ", code)
        --print("response data: ", pretty.write(data))
        --print("queue message: ", pretty.write(msg))
        --print("*** END REQUEST FAILURE ***")
        msg.numRetries = msg.numRetries - 1
        if msg.numRetries == 0 then
          -- it will be removed after this pass through
        --print("Previous request failed for the last time ("..INITIAL_NUM_RETRIES.." times total), it will be dropped from the queue!")
        end
      end
      self:processAt(position + 1) -- recursively do the next item
    end

    -- set global lock
    BUSY = true

    -- msg.method is one of the `http` module methods, i.e. `http.get`, `http.post`, etc.
    if msg.body then
      msg.method(msg.url, msg.headers, msg.body, handler)
    else
      msg.method(msg.url, msg.headers, handler)
    end
  end

  function queue:schedule (msg)
    msg.numRetries = INITIAL_NUM_RETRIES
    table.insert(self, msg)
  end

  function queue:cleanUp ()
    -- clear out expired messages from last time
    position = 1
    while table.maxn(self) >= position do
      if self[position].numRetries <= 0 then
        table.remove(self, position)
      else
        position = position + 1
      end
    end
  end

  function queue:its_showtime ()
    if BUSY then return end
    self:cleanUp()
    self:processAt(1)
  end

  return queue

end