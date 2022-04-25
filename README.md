# usb-gadget-utils

Some useful utilities for configuring USB HID gadget using configfs.

## Utilities

| folder        | main file         | description                                                  |
| ------------- | ----------------- | ------------------------------------------------------------ |
| desc2bin      | convert.sh        | convert the .h header file exported from [HidDescTool](https://www.usb.org/document-library/hid-descriptor-tool) to .bin binary file, which is required in gadget functions setup |
| setup_script  | en_gadget.sh      | automatically setup usb gadget according to information filled in. |
| driver_sample | hid_gadget_test.c | a sample interactive c program to emulate a keyboard or mouse after gadget is set up.<br>(from linux kernel doc, [here](https://www.kernel.org/doc/Documentation/usb/gadget_hid.txt)) |
| python_wrap   | gadget.py         | a wrapper class for send hid instructions from python        |

## Usage

Before using any of these utilities, you should check if your linux kernel as well as your hardware/development board itself support **configuring USB Hid gadget through configfs**.

1. Try finding the mount point of configfs:

    ```bash
    sudo mount -l | grep configfs
    ```

2. if it outputs the mount point of configfs, go to **step 4**; 

3. otherwise try load kernel module and mount it:

    ```bash
    sudo modprobe libcomposite
    CONFIGFS_HOME=XXX
    mount none $CONFIGFS_HOME -t configfs
    ```

    and then retry **step 1**.

    If the output is still empty, you may need to modify kernel settings and compile the kernel, and try **step 3&1** again.

5. If folder `usb_gadget` doesn't exist in `$CONFIGFS_HOME`, you also need to modify kernel settings and compile the kernel.

### desc2bin

1. First download [Hid-Descriptor-Tool](https://www.usb.org/document-library/hid-descriptor-tool) on a **Windows PC**, unzip and run Dt.exe. Edit your own hid descriptor or click "File-Open" and select one from the given samples along with the tool. Click "File-SaveAs" and export the descriptor to a C header file (.h).
2. Upload the header file to your linux device. Within the desc2bin folder, mouseDesc.h and keybrdDesc.h are provided for reference or tests.

3. Then run the convert.sh script to convert the header file to required binary file. 
    ```bash
    cd desc2bin
    sudo chmod +x ./convert.sh #if necessary
    ./convert.sh mouseDesc.h mouse-descriptor.bin
    ```

4. If all goes well, a binary file mouse-descriptor.bin will be generated in current folder, command `hexdump` is useful to check its content:

    ```bash
    hexdump mouse-descriptor.bin
    ```

You can replace the header file and output binary file name in commands above, as you need. The binary file is required in next step.

### setup_script

1. Open the `en_gadget.sh` using your favourite text editor.

2. Edit the Settings between `####[ User Settings begin]#####` and `####[ User Settings end]#####`, referring to the comments following the keys. 

3. Delete or append lines of `function_setup` in `main()`, according to your number of functions.

4. Save and Close.

5. Run the shellscript with sudo:

    ```bash
    cd setup_script
    sudo chmod +x ./en_gadget.sh #if necessary
    sudo ./en_gadget.sh
    ```

If the scipt print the device file like `/dev/hidg0`, `/dev/hidg1` in the end, then the gadget has been set up properly, congratulations.

Note: the script DOES NOT handle any error occurred halfway, you may better look through the script and make clear exactly what it will do before execution.

### driver_sample

**After gadget setup**, `hid_gadget_test.c` could be used to test the hid functions interactively. (Note: this program is collected from [linux kernel documentation about hid gadget](https://www.kernel.org/doc/Documentation/usb/gadget_hid.txt))

1. Assure you have properly set up usb hid gadget in previous steps.

2. Compile the c source file.

    ```bash
    cd driver_sample
    gcc hid_gadget_test.c -o hid_gadget_test
    ```

2. Connect the device to your host PC(or other USB host devices) with a USB cable.

    If there is multiple USB ports on device, make sure you connect the right one.

3. If the host PC has a operating system, check the Device Manager to see if the device is recognized properly as a USB device.

4. Run the program to emulate a keyboard:

    ```bash
    ./hid_gadget /dev/hidgX keyboard
    ```

    Where X should be replaced by your real device number printed by the setup script step, and "keyboard" could also be replaced by "mouse" to emulate a mouse.

5. The program will print all the commands that is supported. For example, type`--left-meta e` and press Enter, the host PC will open explorer on Windows system.

### python_wrap

This is a wrapper class of the given sample program for controlling the gadget in your own python program.

1. Assure you have properly set up usb hid gadget in previous steps.

2. Compile the sample program to dynamic library, so that the C functions can be reused by python.

    ```bash
    cd python_wrap
    sudo chmod +x ./get_so.sh #if necessary
    ./get_so.sh
    ```

    Then `gadget.so` should be compiled in current folder.

3. Import gadget, and write your python code . For example:

    ```python
    from gadget import Gadget
    gkey=Gadget("/dev/hidg0","keyboard")
    gms=Gadget("/dev/hidg1","mouse")
    
    gkey.send("--left-meta e")   # win+e
    gms.send("-65 -65 --b2")     # move left-up and right click
    ```

## References

- https://www.kernel.org/doc/Documentation/usb/gadget_hid.txt
- https://www.kernel.org/doc/Documentation/usb/gadget_configfs.txt
