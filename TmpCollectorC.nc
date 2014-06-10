configuration TmpCollectorC{
  provides interface Read<float> as TmpAverage;
  provides interface StdControl;
}
implementation{
  components TmpCollectorP;
  TmpAverage=TmpCollectorP;
  StdControl=TmpCollectorP;

  components new FakeSensorC() as FakeSensor;
  components new TimerMilliC() as Timer;
  TmpCollectorP.TmpRead->FakeSensor;
  TmpCollectorP.ReadTimer-> Timer;

}