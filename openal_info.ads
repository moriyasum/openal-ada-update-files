package OpenAL_Info is
  procedure Run;
  procedure Init;   --  Added
  procedure List_Playback_Devices;
  procedure List_Capture_Devices;
  procedure Defaults;
--  procedure Open_Device;  This name may conflict with the regular Open_Device
--  procedure Versions; This prototype is on the adb file
  procedure Finish;

end OpenAL_Info;
