class Timer
  def initialise
    mStartTicks = 0
    mPausedTicks = 0

    mPaused = false
    mStarted = false
  end

  def start
    mStarted = true

    mPaused = false

    mStartTicks = $app.frames
  end

  def stop
    # Stop the timer
    mStarted = false

    # Unpause the timer
    mPaused = false

    # Clear tick variables
    mStartTicks = 0
    mPausedTicks = 0
  end

  def pause
    # If the timer is running and isn't already paused
    if mStarted && !mPaused
      # Pause the timer
      mPaused = true

      # Calculate the paused ticks
      mPausedTicks = $app.frames - mStartTicks
      mStartTicks = 0
    end
  end

  def unpause
    # If the timer is running and paused
    if mStarted && mPaused
      # Unpause the timer
      mPaused = false

      # Reset the starting ticks
      mStartTicks = $app.frames - mPausedTicks

      # Reset the paused ticks
      mPausedTicks = 0
    end
  end

  def get_ticks
    # The actual timer time
  	elapsedTicks = 0;

    # If the timer is running
    if mStarted
      # If the timer is paused
      if mPaused
        # Return the number of ticks when the timer was paused
        elapsedTicks = mPausedTicks
      else
        # Return the current time minus the start time
        elapsedTicks = $app.frames - mStartTicks
      end
    end

    return elapsedTicks;
  end
end
