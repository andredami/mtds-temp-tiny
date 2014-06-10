#include "TmpTiny.h"
configuration TmpTinyAppC{}
implementation{
	//main components
	components MainC;
	components TmpTinyC as App;
	components RandomC;
	components new TimerMilliC() as ReadTimer;
	components new TimerMilliC() as DelayTimer;
	components new TimerMilliC() as MessageTimer;
	components ActiveMessageC;
	components new AMSenderC(AM_TMPTINY);
	components new AMReceiverC(AM_TMPTINY);
	components TmpCollectorC;

	App.Boot-> MainC;
	App.TmpControl->TmpCollectorC;
	App.TmpAverageRead->TmpCollectorC;
	App.MessageTimer->MessageTimer;
	App.DelayTimer->DelayTimer;
	App.Packet -> AMSenderC;
  App.AMControl -> ActiveMessageC;
  App.AMSend -> AMSenderC;
  App.Rand -> RandomC;
  App.Receive -> AMReceiverC;

}
