# C:\FlutterFinal\remote_pc_control\pc-agent\agent_service.py
import asyncio
import threading
import logging
import win32serviceutil
import win32service
import win32event
import servicemanager
from agent import agent_main  # Make sure agent.py has agent_main()

logging.basicConfig(
    filename="C:\\FlutterFinal\\remote_pc_control\\pc-agent\\agent_service.log",
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(message)s"
)

class AgentService(win32serviceutil.ServiceFramework):
    _svc_name_ = "PCRemoteAgent"
    _svc_display_name_ = "PC Remote Agent Service"
    _svc_description_ = "Runs PC remote agent in background"

    def __init__(self, args):
        super().__init__(args)
        self.stop_event = win32event.CreateEvent(None, 0, 0, None)

    def SvcStop(self):
        self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING)
        win32event.SetEvent(self.stop_event)

    def SvcDoRun(self):
        servicemanager.LogMsg(
            servicemanager.EVENTLOG_INFORMATION_TYPE,
            servicemanager.PYS_SERVICE_STARTED,
            (self._svc_name_, '')
        )
        t = threading.Thread(target=self.run_agent, daemon=True)
        t.start()
        win32event.WaitForSingleObject(self.stop_event, win32event.INFINITE)

    def run_agent(self):
        try:
            asyncio.run(agent_main())
        except Exception as e:
            logging.error(f"AgentService error: {e}")

if __name__ == "__main__":
    win32serviceutil.HandleCommandLine(AgentService)
