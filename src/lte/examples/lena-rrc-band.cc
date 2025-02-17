#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/mobility-module.h"
#include "ns3/lte-module.h"
#include "ns3/internet-module.h"

using namespace ns3;

int main(int argc, char *argv[])
{
    CommandLine cmd;
    cmd.Parse(argc, argv);

    // Create LTE helper
    Ptr<LteHelper> lteHelper = CreateObject<LteHelper>();

    // Create EPC helper
    Ptr<PointToPointEpcHelper> epcHelper = CreateObject<PointToPointEpcHelper>();
    lteHelper->SetEpcHelper(epcHelper);

    // Create nodes: eNodeB and UE
    NodeContainer enbNodes;
    NodeContainer ueNodes;
    enbNodes.Create(1);
    ueNodes.Create(1);

    // Install mobility model
    MobilityHelper mobility;
    mobility.SetMobilityModel("ns3::ConstantPositionMobilityModel");
    mobility.Install(enbNodes);
    mobility.Install(ueNodes);

    // Install LTE devices to the nodes
    NetDeviceContainer enbLteDevs = lteHelper->InstallEnbDevice(enbNodes);
    NetDeviceContainer ueLteDevs = lteHelper->InstallUeDevice(ueNodes);




    // Install Internet stack on UE nodes
    InternetStackHelper internet;
    internet.Install(ueNodes);



    // Attach UE to the eNodeB
    lteHelper->Attach(ueLteDevs, enbLteDevs.Get(0));

    // Activate a data radio bearer
    enum EpsBearer::Qci qci = EpsBearer::GBR_CONV_VOICE;
    EpsBearer bearer(qci);
    lteHelper->ActivateDataRadioBearer(ueLteDevs, bearer);

    // Change DlEarfcn through RRC messaging
    Ptr<LteEnbRrc> enbRrc = enbLteDevs.Get(0)->GetObject<LteEnbNetDevice>()->GetRrc();
    enbRrc->SetAttribute("DlEarfcn", UintegerValue(100)); // Set new downlink EARFCN

    Simulator::Run();
    Simulator::Destroy();

    return 0;
}