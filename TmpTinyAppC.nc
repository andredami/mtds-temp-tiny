#include "TmpTiny.h"
configuration TmpTinyAppC{}
implementation{
	//main components
	components MainC;
	components TmpTinyC as App;
	components new FakeSensorC() as TmpSensor;
	components TmpCollectorP as TmpCollector;
	components RandomC;
	components new TimerMilliC() as ReadTimer;
	components new TimerMilliC() as DelayTimer;
	components new TimerMilliC() as MessageTimer;
	components ActiveMessageC;
	components new AMSenderC(AM_TMPTINY);
	components new AMReceiverC(AM_TMPTINY);

	App.Boot-> MainC;
	App.TmpControl->TmpCollector;
	App.TmpAverageRead->TmpCollector;
	App.MessageTimer->MessageTimer;
	App.DelayTimer->DelayTimer;
	App.Packet -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Rand -> RandomC;
  App.Receive -> AMReceiverC;
	
	TmpSensor.Random->RandomC;

	components new TimerMilliC() as MeasureTimer;
	TmpCollector.TmpRead->TmpSensor;
	TmpCollector.ReadTimer->MeasureTimer;
}
