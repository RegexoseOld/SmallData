boolean holdTimerPassed = false;

class VisibilityMachine {
  static final int STATE_HIDE = 0;
  static final int STATE_GROW = 1;
  static final int STATE_HOLD = 2;
  static final int STATE_SHRINK = 3;
  
  boolean lock = false;
  int state;
  boolean isVisible = false;
  boolean sizeReached = false;
  long holdDurationMs = 5000;

  VisibilityMachine() {
    this.setState(VisibilityMachine.STATE_HIDE);
  }

  public void start() {
    this.isVisible = true;
    this.setState(VisibilityMachine.STATE_GROW);
  }

  void update() {
    
    switch (this.state) {
    case VisibilityMachine.STATE_HIDE:
      this.isVisible = false;
    case VisibilityMachine.STATE_GROW:
      if (this.checkGrowCriteria() == true) {
        this.setState(VisibilityMachine.STATE_HOLD);
        this.startHoldTimer();
      }
    case VisibilityMachine.STATE_HOLD:
      if (holdTimerPassed) {
        holdTimerPassed = false;
        this.setState(VisibilityMachine.STATE_SHRINK);
      }
    case VisibilityMachine.STATE_SHRINK:
      if (this.checkShrinkCriteria() == true) {
        this.isVisible = false;
        this.setState(VisibilityMachine.STATE_HIDE);
      }
    }
  }

  void startHoldTimer() {
    timer.schedule(new TimerTask() {
      public void run() {
        holdTimerPassed = true;
      }
    }
    , this.holdDurationMs);
  }
  
  public void setState(int state) {
    this.state = state;
  }
  
  public void setSizeReached(boolean value) {
    this.sizeReached = value;
  }

  boolean checkGrowCriteria() {
    return this.sizeReached;
  }

  boolean checkShrinkCriteria() {
    return false;
  }
}
