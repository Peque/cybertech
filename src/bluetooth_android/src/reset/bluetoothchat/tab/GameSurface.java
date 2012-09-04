package reset.bluetoothchat.tab;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.os.Handler;
import android.util.AttributeSet;
import android.util.DisplayMetrics;
import android.view.MotionEvent;
import android.view.SurfaceHolder;
import android.view.SurfaceView;
import android.view.Display;
import android.util.Log;

public class GameSurface extends SurfaceView implements SurfaceHolder.Callback {

	private Context _context;
	private GameThread _thread;
	private GameControls _controls;

	private GameJoystick _joystick;

	private Bitmap _pointer;
	
	private int canvasWidth;
	private int canvasHeight;
	private boolean firstDraw = true;
	 
	public GameSurface(Context context, AttributeSet attributeSet) {
		super(context, attributeSet);
		// TODO Auto-generated constructor stub
		_context = context;
		init();
	}

	public GameSurface(Context context) {
		super(context);
		// TODO Auto-generated constructor stub
		_context = context;
		init();
	}
	
	@Override
	public boolean onTouchEvent(MotionEvent event) {
		// TODO Auto-generated method stub
		_controls.update(event);
		return super.onTouchEvent(event);
	}
	
//	@Override
//	protected void onMeasure(int widthMeasureSpec, int heightMeasureSpec) {
//		// TODO Auto-generated method stub
//		super.onMeasure(widthMeasureSpec, heightMeasureSpec);
//		canvasWidth = widthMeasureSpec;
//		canvasHeight = heightMeasureSpec;
//	}

	private void init(){
		//initialize our screen holder
		SurfaceHolder holder = getHolder();
		holder.addCallback( this);
		
		_pointer = (Bitmap)BitmapFactory.decodeResource(getResources(), R.drawable.ic_launcher);
		
		//initialize our game engine

		//initialize our Thread class. A call will be made to start it later
		_thread = new GameThread(holder, _context, new Handler(),this);
		setFocusable(true);


		_joystick = new GameJoystick(getContext().getResources());
		//contols
		_controls = new GameControls(this, _joystick);
	}


	public void doDraw(Canvas canvas){

		//update the pointer
		_controls.update(null);
		
		//draw the pointer
		canvas.drawBitmap(_pointer, _controls._pointerPosition.x, _controls._pointerPosition.y, null);

		//draw the joystick background
		canvas.drawBitmap(_joystick.get_joystickBg(), _controls.getInitx() - _joystick.get_joystick_bg_width() / 2, _controls.getInity() - _joystick.get_joystick_bg_height() / 2, null);

		//draw the dragable joystick
		canvas.drawBitmap(_joystick.get_joystick(),_controls._touchingPoint.x - _joystick.get_joystick_width() / 2, _controls._touchingPoint.y - _joystick.get_joystick_height() / 2, null);
		
		
		if (firstDraw ) {
			canvasWidth = this.getWidth();
			canvasHeight = this.getHeight();
			firstDraw = false;
		}

	}



	//these methods are overridden from the SurfaceView super class. They are automatically called 
	//when a SurfaceView is created, resumed or suspended.
	@Override 
	public void surfaceChanged(SurfaceHolder arg0, int arg1, int arg2, int arg3) {}
	
	private boolean retry;
	
	@Override 
	public void surfaceDestroyed(SurfaceHolder arg0) {
		retry = true;
		//code to end gameloop
		_thread.state = GameThread.STOPED;
		while (retry) {
			try {
				//code to kill Thread
				_thread.join();
				retry = false;
			} catch (InterruptedException e) {
			}
		}

	}

	@Override 
	public void surfaceCreated(SurfaceHolder arg0) {
		if(_thread.state==GameThread.PAUSED){
			//When game is opened again in the Android OS
			_thread = new GameThread(getHolder(), _context, new Handler(),this);
			_thread.start();
		}else{
			//creating the game Thread for the first time
			_thread.start();
		}
	}

	public void Update() {
		// TODO Auto-generated method stub

	}
	
	public GameJoystick get_joystick() {
		return _joystick;
	}
	
	public int getCanvasWidth() {
		return canvasWidth;
	}
	
	public int getCanvasHeight() {
		return canvasHeight;
	}
	
	public int getPointerWidth() {
		return _pointer.getWidth();
	}
	
	public int getPointerHeight() {
		return _pointer.getHeight();
	}


}
