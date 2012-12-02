package reset.bluetoothchat.tab;

import java.nio.FloatBuffer;
import java.util.Scanner;

import org.xmlpull.v1.XmlPullParser;

import android.app.ActionBar;
import android.app.Activity;
import android.app.FragmentTransaction;
import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.Intent;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentPagerAdapter;
import android.support.v4.view.ViewPager;
import android.support.v4.app.NavUtils;
import android.util.AttributeSet;
import android.util.Log;
import android.util.Xml;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.View.OnClickListener;
import android.view.WindowManager;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;

public class BluetoothChat extends FragmentActivity implements ActionBar.TabListener {

  // Swipe funcionality declarations
    SectionsPagerAdapter mSectionsPagerAdapter;
    
    /**
     * The {@link ViewPager} that will host the section contents.
     */
    ModifiedViewPager mViewPager;
    
    // Joystick tab for avoiding swiping on it
    private static final int JOYSTICK_TAB = 3;
    
  // Bluetooth chat declarations
    
    // Debugging
    private static final String TAG = "BluetoothChat";
    private static final boolean D = true;

    // Message types sent from the BluetoothChatService Handler
    public static final int MESSAGE_STATE_CHANGE = 1;
    public static final int MESSAGE_READ = 2;
    public static final int MESSAGE_WRITE = 3;
    public static final int MESSAGE_DEVICE_NAME = 4;
    public static final int MESSAGE_TOAST = 5;

    // Key names received from the BluetoothChatService Handler
    public static final String DEVICE_NAME = "device_name";
    public static final String TOAST = "toast";

    // Intent request codes
    private static final int REQUEST_CONNECT_DEVICE_SECURE = 1;
    private static final int REQUEST_CONNECT_DEVICE_INSECURE = 2;
    private static final int REQUEST_ENABLE_BT = 3;

    // Name of the connected device
    private String mConnectedDeviceName = null;
    // Array adapter for the conversation thread
    private ArrayAdapter<String> mConversationArrayAdapter;
    // String buffer for outgoing messages
    private StringBuffer mOutStringBuffer;
    // Local Bluetooth adapter
    private BluetoothAdapter mBluetoothAdapter = null;
    // Member object for the chat services
    private BluetoothChatService mChatService = null;

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if(D) Log.e(TAG, "++ ON CREATE ++");
        setContentView(R.layout.real_main);

     // Create the adapter that will return a fragment for each of the three primary sections
        // of the app.
        mSectionsPagerAdapter = new SectionsPagerAdapter(getSupportFragmentManager());

        // Force screen on
        getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
        
        // Set up the action bar.
        final ActionBar actionBar = getActionBar();
        actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_TABS);

        // Set up the ViewPager with the sections adapter.
        mViewPager = (ModifiedViewPager) findViewById(R.id.pager);
        mViewPager.setAdapter(mSectionsPagerAdapter);
        mViewPager.setOffscreenPageLimit(3);

        // When swiping between different sections, select the corresponding tab.
        // We can also use ActionBar.Tab#select() to do this if we have a reference to the
        // Tab.
        mViewPager.setOnPageChangeListener(new ViewPager.SimpleOnPageChangeListener() {
        	
            @Override
            public void onPageSelected(int position) {
                actionBar.setSelectedNavigationItem(position);
                mViewPager.setSwipingEnabled(true);
                mSectionsPagerAdapter.pidFragment.pidLockButton.setChecked(false); 
                mSectionsPagerAdapter.mFragment.toggleUpdate.setChecked(false); 
                if (mSectionsPagerAdapter.mFragment.timer != null) {
                	mSectionsPagerAdapter.mFragment.timer.cancel();
                	mSectionsPagerAdapter.mFragment.timer.purge();
                }               
            }
            
            @Override
        	public void onPageScrolled(int position, float positionOffset,
        			int positionOffsetPixels) {
        		// TODO Auto-generated method stub
        		super.onPageScrolled(position, positionOffset, positionOffsetPixels);
        		// If we are on Joystick Tab, hide the key board after 2000ms
        		final Handler handler = new Handler();
        		handler.postDelayed(new Runnable() {
        			
        		  @Override
        		  public void run() {
        		    //Do something after 2000ms
        			  if (getActionBar().getSelectedNavigationIndex() == JOYSTICK_TAB) {
                      	InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
                      	imm.hideSoftInputFromWindow(mViewPager.getWindowToken(), imm.HIDE_NOT_ALWAYS );
                      	if(mSectionsPagerAdapter.jFragment.buttonLock.isChecked())
                      		mViewPager.setSwipingEnabled(false);
                      }
        		  }
        		}, 1500);
            } 
        });

        // For each of the sections in the app, add a tab to the action bar.
        for (int i = 0; i < mSectionsPagerAdapter.getCount(); i++) {
            // Create a tab with text corresponding to the page title defined by the adapter.
            // Also specify this Activity object, which implements the TabListener interface, as the
            // listener for when this tab is selected.
            actionBar.addTab(
                    actionBar.newTab()
                            .setText(mSectionsPagerAdapter.getPageTitle(i))
                            .setTabListener(this));
        }
        // Request No title bar
        actionBar.setDisplayShowHomeEnabled(false);
        actionBar.setDisplayShowTitleEnabled(false);
        
	    // Get local Bluetooth adapter
        mBluetoothAdapter = BluetoothAdapter.getDefaultAdapter();
        
        // If the adapter is null, then Bluetooth is not supported
        if (mBluetoothAdapter == null) {
            Toast.makeText(this, "Bluetooth is not available", Toast.LENGTH_LONG).show();
            finish();
            return;
        }
        
        // If BT is not on, request that it be enabled.
        // setupChat() will then be called during onActivityResult
        if (!mBluetoothAdapter.isEnabled()) {
            Intent enableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE);
            startActivityForResult(enableIntent, REQUEST_ENABLE_BT);
        // Otherwise, setup the chat session
        } else {
            if (mChatService == null) setupChat();
        }
    }
    
    @Override
    public void onStart() {
        super.onStart();
        if(D) Log.e(TAG, "++ ON START ++");
    }
    
    @Override
    public synchronized void onResume() {
        super.onResume();
        if(D) Log.e(TAG, "+ ON RESUME +");

        // Performing this check in onResume() covers the case in which BT was
        // not enabled during onStart(), so we were paused to enable it...
        // onResume() will be called when ACTION_REQUEST_ENABLE activity returns.
        if (mChatService != null) {
            // Only if the state is STATE_NONE, do we know that we haven't started already
            if (mChatService.getState() == BluetoothChatService.STATE_NONE) {
              // Start the Bluetooth chat services
              mChatService.start();
            }
        }
    }
    
    @Override
    public synchronized void onPause() {
        super.onPause();
        if(D) Log.e(TAG, "- ON PAUSE -");
    }

    @Override
    public void onStop() {
        super.onStop();
        if(D) Log.e(TAG, "-- ON STOP --");
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        // Stop the Bluetooth chat services
        if (mChatService != null) mChatService.stop();
        if(D) Log.e(TAG, "--- ON DESTROY ---");
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.option_menu, menu);
        return true;
    }

    @Override
    public void onTabUnselected(ActionBar.Tab tab, FragmentTransaction fragmentTransaction) {
    }

    @Override
    public void onTabSelected(ActionBar.Tab tab, FragmentTransaction fragmentTransaction) {
    	 // When the given tab is selected, switch to the corresponding page in the ViewPager.
        mViewPager.setCurrentItem(tab.getPosition());
    }

    @Override
    public void onTabReselected(ActionBar.Tab tab, FragmentTransaction fragmentTransaction) {
    }
    
    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        Intent serverIntent = null;
        switch (item.getItemId()) {
        case R.id.secure_connect_scan:
            // Launch the DeviceListActivity to see devices and do scan
            serverIntent = new Intent(this, DeviceListActivity.class);
            startActivityForResult(serverIntent, REQUEST_CONNECT_DEVICE_SECURE);
            return true;
        case R.id.insecure_connect_scan:
            // Launch the DeviceListActivity to see devices and do scan
            serverIntent = new Intent(this, DeviceListActivity.class);
            startActivityForResult(serverIntent, REQUEST_CONNECT_DEVICE_INSECURE);
            return true;
        case R.id.discoverable:
            // Ensure this device is discoverable by others
            ensureDiscoverable();
            return true;
        }
        return false;
    }
    
    @Override
    	public void onConfigurationChanged(Configuration newConfig) {
    		// TODO Auto-generated method stub
    		super.onConfigurationChanged(newConfig);
    		
    		// Destroy and recreate joystick fragment
    		mSectionsPagerAdapter.destroyItem(mViewPager, JOYSTICK_TAB, mSectionsPagerAdapter.jFragment.getJoystickFragment());
    		mSectionsPagerAdapter.instantiateItem(mViewPager, JOYSTICK_TAB);
    }
    
    private void setupChat() {
        Log.d(TAG, "setupChat()");

        // Initialize the array adapter for the conversation thread
        mConversationArrayAdapter = new ArrayAdapter<String>(this, R.layout.message);

//            mConversationView = (ListView) findViewById(R.id.in);
//            mConversationView.setAdapter(mConversationArrayAdapter);

        // Initialize the BluetoothChatService to perform bluetooth connections
        mChatService = new BluetoothChatService(this, mHandler);

        // Initialize the buffer for outgoing messages
        mOutStringBuffer = new StringBuffer("");
    }
    
    // The action listener for the EditText widget, to listen for the return key
    private TextView.OnEditorActionListener mWriteListener =
        new TextView.OnEditorActionListener() {
        public boolean onEditorAction(TextView view, int actionId, KeyEvent event) {
            // If the action is a key-up event on the return key, send the message
            if (actionId == EditorInfo.IME_NULL && event.getAction() == KeyEvent.ACTION_UP) {
                String message = view.getText().toString();
                sendMessage(message);
            }
            if(D) Log.i(TAG, "END onEditorAction");
            return true;
        }
    };
    
    // The Handler that gets information back from the BluetoothChatService
    private final Handler mHandler = new Handler() {
        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
            case MESSAGE_STATE_CHANGE:
                if(D) Log.i(TAG, "MESSAGE_STATE_CHANGE: " + msg.arg1);
                switch (msg.arg1) {
                case BluetoothChatService.STATE_CONNECTED:
//                    setStatus(getString(R.string.title_connected_to, mConnectedDeviceName));
                	Toast.makeText(getApplicationContext(), getString(R.string.title_connected_to) + mConnectedDeviceName, Toast.LENGTH_SHORT).show();
                    mConversationArrayAdapter.clear();
                    break;
                case BluetoothChatService.STATE_CONNECTING:
//                    setStatus(R.string.title_connecting);
                	Toast.makeText(getApplicationContext(), R.string.title_connecting, Toast.LENGTH_SHORT).show();
                    break;
                case BluetoothChatService.STATE_LISTEN:
                case BluetoothChatService.STATE_NONE:
//                    setStatus(R.string.title_not_connected);
                	Toast.makeText(getApplicationContext(), R.string.title_not_connected, Toast.LENGTH_SHORT).show();
                    break;
                }
                break;
            case MESSAGE_WRITE:
                byte[] writeBuf = (byte[]) msg.obj;
                // construct a string from the buffer
                String writeMessage = new String(writeBuf);
                mConversationArrayAdapter.add("Me:  " + writeMessage);
                break;
            case MESSAGE_READ:
                byte[] readBuf = (byte[]) msg.obj;
                // construct a string from the valid bytes in the buffer
                String readMessage = new String(readBuf, 0, msg.arg1);
                parse (readMessage);
                mConversationArrayAdapter.add(mConnectedDeviceName+":  " + readMessage);
                break;
            case MESSAGE_DEVICE_NAME:
                // save the connected device's name
                mConnectedDeviceName = msg.getData().getString(DEVICE_NAME);
                Toast.makeText(getApplicationContext(), "Connected to "
                               + mConnectedDeviceName, Toast.LENGTH_SHORT).show();
                break;
            case MESSAGE_TOAST:
                Toast.makeText(getApplicationContext(), msg.getData().getString(TOAST),
                               Toast.LENGTH_SHORT).show();
                break;
            }
        }
    };
    
    /**
     * Sends a message.
     * @param message  A string of text to send.
     * Will return 0 if it's not connected to target
     * 				1 if message was sent
     * 				2 if it is connected but there is no message to send
     */
    public int sendMessage(String message) {
        // Check that we're actually connected before trying anything
        if (mChatService.getState() != BluetoothChatService.STATE_CONNECTED) {
            Toast.makeText(this, R.string.not_connected, Toast.LENGTH_SHORT).show();
            return 0;
        }

        // Check that there's actually something to send
        if (message.length() > 0) {
            // Get the message bytes and tell the BluetoothChatService to write
            byte[] send = message.getBytes();
            mChatService.write(send);

            // Reset out string buffer to zero and clear the edit text field
            mOutStringBuffer.setLength(0);
            return 1;
        }
        
        return 2;
    }
    
    public boolean isConnected () {
    	if (mChatService.getState() != BluetoothChatService.STATE_CONNECTED) return false;
    	else return true;
    }
    
    private void ensureDiscoverable() {
        if(D) Log.d(TAG, "ensure discoverable");
        if (mBluetoothAdapter.getScanMode() !=
            BluetoothAdapter.SCAN_MODE_CONNECTABLE_DISCOVERABLE) {
            Intent discoverableIntent = new Intent(BluetoothAdapter.ACTION_REQUEST_DISCOVERABLE);
            discoverableIntent.putExtra(BluetoothAdapter.EXTRA_DISCOVERABLE_DURATION, 300);
            startActivity(discoverableIntent);
        }
    }
    
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if(D) Log.d(TAG, "onActivityResult " + resultCode);
        switch (requestCode) {
        case REQUEST_CONNECT_DEVICE_SECURE:
            // When DeviceListActivity returns with a device to connect
            if (resultCode == Activity.RESULT_OK) {
                connectDevice(data, true);
            }
            break;
        case REQUEST_CONNECT_DEVICE_INSECURE:
            // When DeviceListActivity returns with a device to connect
            if (resultCode == Activity.RESULT_OK) {
                connectDevice(data, false);
            }
            break;
        case REQUEST_ENABLE_BT:
            // When the request to enable Bluetooth returns
            if (resultCode == Activity.RESULT_OK) {
                // Bluetooth is now enabled, so set up a chat session
                setupChat();
            } else {
                // User did not enable Bluetooth or an error occurred
                Log.d(TAG, "BT not enabled");
                Toast.makeText(this, R.string.bt_not_enabled_leaving, Toast.LENGTH_SHORT).show();
                finish();
            }
        }
    }
    
    private void connectDevice(Intent data, boolean secure) {
        // Get the device MAC address
        String address = data.getExtras()
            .getString(DeviceListActivity.EXTRA_DEVICE_ADDRESS);
        // Get the BluetoothDevice object
        BluetoothDevice device = mBluetoothAdapter.getRemoteDevice(address);
        // Attempt to connect to the device
        mChatService.connect(device, secure);
    }
    
    public TextView.OnEditorActionListener getmWriteListener() {
		return mWriteListener;
	}
    
    public ArrayAdapter<String> getmConversationArrayAdapter() {
		return mConversationArrayAdapter;
	}
    
    private void parse (String message){
    	if (message.compareTo("ping") == 0) 
    		sendMessage("pong");
    	else {
	    	String[] parameters = message.split(",");
	    	
			if ((parameters.length == 4) && 
			    (parameters[0].compareTo(getString(R.string.PID_Values_Label)) == 0)) {
				mSectionsPagerAdapter.pidFragment.setKp(Float.parseFloat(parameters[1]));
				mSectionsPagerAdapter.pidFragment.setKi(Float.parseFloat(parameters[2]));
				mSectionsPagerAdapter.pidFragment.setKd(Float.parseFloat(parameters[3]));
			}
			else if ((parameters.length == 3) && 
			    (parameters[0].compareTo(getString(R.string.Battery_Label)) == 0)) {
				mSectionsPagerAdapter.mFragment.setPBat(Float.parseFloat(parameters[1]));
				mSectionsPagerAdapter.mFragment.setDBat(Float.parseFloat(parameters[2]));				
			}
			else if ((parameters.length == 2) && 
				    (parameters[0].compareTo(getString(R.string.Line_Position_Label)) == 0)) {
					mSectionsPagerAdapter.mFragment.setLPos(Float.parseFloat(parameters[1]));			
				}
//			else
//				sendMessage(getString(R.string.get_PID));
    	}
    	
    }
    
    // Fragment Pager Adapter sets several fragments as view contents for the view pager.
    
    /**
     * A {@link FragmentPagerAdapter} that returns a fragment corresponding to one of the primary
     * sections of the app.
     */
    public class SectionsPagerAdapter extends FragmentPagerAdapter {
    	
        ConsoleFragment cFragment = new ConsoleFragment();
        PidFragment pidFragment = new PidFragment();
        JoystickFragment jFragment = new JoystickFragment();
        MonitorFragment mFragment = new MonitorFragment();

        public SectionsPagerAdapter(FragmentManager fm) {
            super(fm);
        }
 
        @Override
        public Fragment getItem(int i) {
        	Bundle args;
        	 switch (i) {
             case 0:           	 
                 args = new Bundle();
                 args.putInt(cFragment.ARG_SECTION_NUMBER, i + 1);
                 args.putString(cFragment.ARG_FRAGMENT_NAME, "CONSOLE");
                 cFragment.setArguments(args);
                 return cFragment;
             case 1:  	 
            	 args = new Bundle();
            	 args.putInt(pidFragment.ARG_SECTION_NUMBER, i + 1);
                 args.putString(pidFragment.ARG_FRAGMENT_NAME, "PID_TUNING");
                 pidFragment.setArguments(args);
                 return pidFragment;
             case 2:          	 
                 args = new Bundle();
                 args.putInt(mFragment.ARG_SECTION_NUMBER, i + 1);
                 args.putString(mFragment.ARG_FRAGMENT_NAME, "MONITOR");
                 mFragment.setArguments(args);
                 return mFragment;
             case 3:          	 
                 args = new Bundle();
                 args.putInt(jFragment.ARG_SECTION_NUMBER, i + 1);
                 args.putString(jFragment.ARG_FRAGMENT_NAME, "CONTROL");
                 jFragment.setArguments(args);
                 return jFragment;
             default:
            	 ConsoleFragment dummy = new ConsoleFragment();
                 args = new Bundle();
                 args.putInt(dummy.ARG_SECTION_NUMBER, i + 1);
                 args.putString(dummy.ARG_FRAGMENT_NAME, "Console");
                 dummy.setArguments(args);
                 return dummy;
        	}  
        }

        @Override
        public int getCount() {
            return 4;
        }

        @Override
        public CharSequence getPageTitle(int position) {
            switch (position) {
                case 0: return getString(R.string.title_section1).toUpperCase();
                case 1: return getString(R.string.title_section2).toUpperCase();
                case 2: return getString(R.string.title_section3).toUpperCase();
                case 3: return getString(R.string.title_section4).toUpperCase();
            }
            return null;
        }
    }
}
