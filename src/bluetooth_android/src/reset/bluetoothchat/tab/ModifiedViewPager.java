package reset.bluetoothchat.tab;

import android.content.Context;
import android.support.v4.view.ViewPager;
import android.util.AttributeSet;
import android.view.MotionEvent;

public class ModifiedViewPager extends ViewPager {


	private boolean enabled = true;

	public ModifiedViewPager(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
	}

	public ModifiedViewPager(Context context, AttributeSet attrs) {
		super(context, attrs);
		// TODO Auto-generated constructor stub
	}

	@Override
	public boolean onTouchEvent(MotionEvent event) {
	    if (this.enabled) {
	        return super.onTouchEvent(event);
	    }

	    return false;
	}

	@Override
	public boolean onInterceptTouchEvent(MotionEvent event) {
	    if (this.enabled) {
	        return super.onInterceptTouchEvent(event);
	    }

	    return false;
	}

	public void setPagingEnabled(boolean enabled) {
	    this.enabled = enabled;
	}

}
