from ctypes import *
import sys,os

class Gadget():
	"""
	a wrap class for using gadget
	"""
	def __init__(self,dev:str,type:str) -> None:
		try:
			self.gadget_c=cdll.LoadLibrary(os.path.dirname( __file__ )+"/gadget.so") 
		except:
			print("load gadget.so failed. Run ./get_so.sh first.")
			exit()
		try:
			self.fp=open(dev,'wb') # note this 'b', write binary to file
		except:
			print("open gadget device %s failed. Configured properly?"%dev,file=sys.stderr)
			exit()
		self.type=type
		if self.type not in ["keyboard","mouse","joystick"]:
			raise "unknown gadget type"
	def __del__(self):
		self.fp.close()
	def send(self,keystr:str):
		inputBuf=c_char_p(keystr.encode('utf-8'))
		report=create_string_buffer(8)
		hold=c_int()
		if self.type=="keyboard":
			toSend=self.gadget_c.keyboard_fill_report((report),inputBuf,byref(hold))
		elif self.type=="mouse":
			toSend=self.gadget_c.mouse_fill_report((report),inputBuf,byref(hold))
		elif self.type=="joystick":
			toSend=self.gadget_c.joystick_fill_report((report),inputBuf,byref(hold))
		print(toSend,repr(report.raw[0:toSend]))

		nw=self.fp.write(report.raw[0:toSend])
		print(nw)
		self.fp.flush() # important!!! because of the existence of output cache
		zbytes=b'\0\0\0\0\0\0\0\0'
		if not hold:
			self.fp.write(zbytes[0:toSend])# important!!! the host device may lost response if skip
			self.fp.flush() # important!!! because of the existence of output cache



# gkey=Gadget("/dev/hidg0","keyboard")
# gms=Gadget("/dev/hidg1","mouse")

# gkey.send("--left-meta e")   # win+e
# gms.send("-65 -65 --b2")     # move left-up and right click
