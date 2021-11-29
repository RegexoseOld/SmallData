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
    this.setSizeReached(false);
    this.setState(VisibilityMachine.STATE_GROW);
  }

  void update() {
    switch (this.state) {
    case VisibilityMachine.STATE_GROW:
      if (this.checkGrowCriteria() == true) {
        this.setState(VisibilityMachine.STATE_HOLD);
      }
      break;
    case VisibilityMachine.STATE_HOLD:
      if (holdTimerPassed == true) {
        this.setState(VisibilityMachine.STATE_SHRINK);
      }
      break;
    case VisibilityMachine.STATE_SHRINK:
      if (this.checkShrinkCriteria() == true) {
        this.setState(VisibilityMachine.STATE_HIDE);
      }
      break;
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
    switch (state) {
    case VisibilityMachine.STATE_HIDE:
      this.isVisible = false;
      break;
    case VisibilityMachine.STATE_GROW:
      this.isVisible = true;
      break;
    case VisibilityMachine.STATE_HOLD:
      this.setSizeReached(false);
      this.startHoldTimer();
    case  VisibilityMachine.STATE_SHRINK:
      holdTimerPassed = false;
      break;
    }
    //println("settings state to " +  state + this);
    this.state = state;
  }

  public void setSizeReached(boolean value) {
    this.sizeReached = value;
  }

  boolean checkGrowCriteria() {
    return this.sizeReached;
  }

  boolean checkShrinkCriteria() {
    return this.sizeReached;
  }
}
