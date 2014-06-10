#include "TmpTiny.h"

module TmpTinyC{
	uses interface Boot;
	uses interface StdControl as TmpControl;
	uses interface Read<uint16_t> as TmpAverageRead;
	uses interface Timer<TMilli> as MessageTimer;
	uses interface Timer<TMilli> as DelayTimer;
	uses interface Packet;
  	uses interface AMSend;
  	uses interface Receive;
  	uses interface SplitControl as AMControl;
  	uses interface Random as Rand;
}

implementation{
	message_t pkt;
	bool busy=FALSE;

	event void Boot.booted(){
 		dbg("default","%s | Node %d started\n", sim_time_string(), TOS_NODE_ID);
   		call AMControl.start();
   		if(TOS_NODE_ID){
   			call TmpControl.start();
		}
	}

	event void AMControl.startDone(error_t err) {
		dbg("default","%s | Node %d AMControl.startDone()\n", sim_time_string(), TOS_NODE_ID);
	    if (err == SUCCESS) {
	      if(TOS_NODE_ID==0){
	      	dbg("default","%s | SINK %d starting message timer\n", sim_time_string(), TOS_NODE_ID);
	      	 call MessageTimer.startPeriodic(5000);
	      }
	    } else {
	      call AMControl.start();
		}
	}
	

	event void MessageTimer.fired(){
		
		dbg("default","%s | SINK %d message timer fired\n",sim_time_string(),TOS_NODE_ID);
		if(!busy){
			uint16_t nodeid = (call Rand.rand16()) % NUMBER_OF_NODES;				
			TmpRequest* msg = (TmpRequest*)(call Packet.getPayload(&pkt,sizeof(TmpRequest)));
			msg->nodeid = nodeid;
			if (call AMSend.send(AM_BROADCAST_ADDR,&pkt, sizeof(TmpRequest)) == SUCCESS) {
	       		busy = TRUE;
	       		dbg("default","%s | SINK %d message sent to %d\n",sim_time_string(),TOS_NODE_ID,msg->nodeid);
	    }
			
		}
	}
	void respondToSingleRequest(){
		dbg("default","%s | NODE %d: Reading average.\n",  sim_time_string(),TOS_NODE_ID);
		//read and compute the average
		call TmpAverageRead.read();
	}

	void respondToBroadcastRequest(){
		uint16_t delay=call Rand.rand16()%500;
		dbg("default","%s | NODE %d: Received broadcast request, delay of: %d \n", sim_time_string(), TOS_NODE_ID, delay);
		call DelayTimer.startOneShot(delay);
	}
	

	void onTmpMessageReceived(uint8_t nodeid,uint16_t measure){
		dbg("default","%s | SINK %d: Received average from %d , value:%d\n", sim_time_string(),TOS_NODE_ID, nodeid,measure);
	}

	void onTmpRequestReceived(uint16_t nodeid){
		if(TOS_NODE_ID == nodeid){
			respondToSingleRequest();
		}else if(nodeid == 0){//0 is considered the broadcast addr
			respondToBroadcastRequest();
		}
	}

	

	event void DelayTimer.fired(){
		//the delay for the broadcast request is fired
		respondToSingleRequest();
	}

	event void TmpAverageRead.readDone(error_t result,uint16_t val){
		//send the packet TmpMessage which contains the measure
		if(result==SUCCESS){
			TmpMessage* msg=(TmpMessage*) call Packet.getPayload(&pkt,sizeof(TmpMessage));
			msg->measure=val;
			msg->nodeid=TOS_NODE_ID;
			if (call AMSend.send(AM_BROADCAST_ADDR,&pkt, sizeof(TmpMessage)) == SUCCESS) {
				dbg("default","%s | NODE %d: sent average, value:%d\n", sim_time_string(),TOS_NODE_ID, val);
        		busy = TRUE;
      		}
		}
	}
	
	event void AMSend.sendDone(message_t* msg, error_t err) {
    	if (&pkt == msg) busy = FALSE;
    	//dbg("default","%s | NODE %d: send done\n",sim_time_string(),TOS_NODE_ID);
 		if(err==FAIL){
 			dbgerror("error", "%s | NODE %d: error send has failed!!!\n", sim_time_string(),TOS_NODE_ID);
 		}
  	}

  	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){
		//if node 0 write the received tmp
		dbg("default","%s | NODE %d: message received\n",sim_time_string(),TOS_NODE_ID);
		if (TOS_NODE_ID==0&&len==sizeof(TmpMessage)){
			TmpMessage* measpck= (TmpMessage*) payload;
			onTmpMessageReceived(measpck->nodeid,measpck->measure);
		}else if (len ==sizeof(TmpRequest)){
			TmpRequest* reqpck= (TmpRequest*) payload;
			onTmpRequestReceived(reqpck->nodeid);
		}
		return msg;
	}

	event void AMControl.stopDone(error_t res){}

	


}