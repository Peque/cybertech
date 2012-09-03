package reset.bluetoothchat.tab;

import android.graphics.Point;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.View.OnTouchListener;

public class GameControls implements OnTouchListener{

	public float initx;
	public float inity;
	public Point _touchingPoint = new Point();  // Where my finger currently is
	public Point _pointerPosition = new Point(); // Where the bitmap i'm moving currently is
	private Boolean _dragging = false;
	
	private GameSurface gSurface;
	private GameJoystick gJoystick;
	

	
	public GameControls(GameSurface s, GameJoystick j) {
		// TODO Auto-generated constructor stub
		gSurface = s;
		gJoystick = j;
	}
	
	

	@Override
	public boolean onTouch(View v, MotionEvent event) {

		update(event);
		return true;
	}

	private MotionEvent lastEvent;
	
	public void update(MotionEvent event){

		if (event == null && lastEvent == null)
		{
			return;
		}else if(event == null && lastEvent != null){
			event = lastEvent;
		}else{
			lastEvent = event;
		}
		//drag drop 
		if ( event.getAction() == MotionEvent.ACTION_DOWN ){
			initx = event.getX();
			inity = event.getY();
			_dragging = true;
		}else if ( event.getAction() == MotionEvent.ACTION_UP){
			_dragging = false;
		}
		

		if ( _dragging ){
			// get the pos
			_touchingPoint.x = (int)event.getX();
			_touchingPoint.y = (int)event.getY();

			// bound to a box
			if( _touchingPoint.x <  initx - (gJoystick.get_joystick_bg_width() / 2) ){
				_touchingPoint.x = (int) (initx - (gJoystick.get_joystick_bg_width() / 2)) ;
			}
			if ( _touchingPoint.x > initx + (gJoystick.get_joystick_bg_width() / 2)){
				_touchingPoint.x = (int) (initx + (gJoystick.get_joystick_bg_width() / 2));
			}
			if (_touchingPoint.y < inity - (gJoystick.get_joystick_bg_height() / 2)){
				_touchingPoint.y = (int) (inity - (gJoystick.get_joystick_bg_height() / 2));
			}
			if ( _touchingPoint.y > inity + (gJoystick.get_joystick_bg_height() / 2) ){
				_touchingPoint.y = (int) (inity + (gJoystick.get_joystick_bg_height() / 2));
			}

			//get the angle
			double angle = Math.atan2(_touchingPoint.y - inity,_touchingPoint.x - initx)/(Math.PI/180);
			
			// Move the beetle in proportion to how far 
			// the joystick is dragged from its center
			_pointerPosition.y += (_touchingPoint.y - inity) / 7;
			_pointerPosition.x += (_touchingPoint.x - initx) / 7;
			
			

			//make the pointer go thru
			if ( _pointerPosition.x > gSurface.getCanvasWidth() - gSurface.getPointerWidth() )
			{
				_pointerPosition.x= (int) gSurface.getCanvasWidth() - gSurface.getPointerWidth();
			}

			if ( _pointerPosition.x < 0 ){
				_pointerPosition.x = 0;
			}

			if (_pointerPosition.y > gSurface.getCanvasHeight() - gSurface.getPointerHeight()){
				_pointerPosition.y = (int) gSurface.getCanvasHeight() - gSurface.getPointerHeight();
			}
			if (_pointerPosition.y < 0){
				_pointerPosition.y = 0;
			}

		}else if (!_dragging)
		{
			// Snap back to center when the joystick is released
			_touchingPoint.x = (int) initx;
			_touchingPoint.y = (int) inity;
			//shaft.alpha = 0;
		}
	}
	
	public float getInitx() {
		return initx;
	}
	
	public float getInity() {
		return inity;
	}
	
}
