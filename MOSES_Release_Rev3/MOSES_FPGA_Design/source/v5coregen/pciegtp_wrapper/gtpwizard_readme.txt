

                    Core Name: Xilinx Virtex-5 RocketIO GTP Wizard
                    Version: 1.7
                    Release Date: October 10, 2007


================================================================================

This document contains the following sections:

1. Introduction
2. New Features
3. Resolved Issues
4. Known Issues
5. Technical Support
6. Core Release History

================================================================================

1. INTRODUCTION

For the most recent updates to the IP installation instructions for this core,
please go to:

   http://www.xilinx.com/ipcenter/coregen/ip_update_install_instructions.htm


For system requirements:

   http://www.xilinx.com/ipcenter/coregen/ip_update_system_requirements.htm



This file contains release notes for the Xilinx LogiCORE Virtex-5 RocketIO GTP Wizard v1.7
solution. For the latest core updates, see the product page at:

   http://www.xilinx.com/xlnx/xebiz/designResources/ip_product_details.jsp?key=V5_RocketIO_Wizard


2. NEW FEATURES

   - Extended Virtex-5 lxt package support


3. RESOLVED ISSUES

   - CR445534 - Change OBSAI protocol setting to make ALIGN_COMMA_WORD = 2
   - Changed PLL_SATA attribute to FALSE per Virtex-5 RocketIO GTP Transceiver User Guide (UG196) v1.4
   - This version provides a workaround for the Synplicity issue outlined in AR29248
      - This issue occurs because a new attribute (PCS_COM_CFG) is missing in the Synplicity release
      - A workaround is provided by setting this attribute in the UCF file
      - This issue will be fixed in synplify v9.0. There is also a patch available for v8.9
      - This version has been tested with v8.8 and v8.9 of Synplify


4. KNOWN ISSUES

   The following are known issues for v1.7 of this core at time of release:

   - If you set the comma alignment smaller than the datapath width, incoming
     data can be aligned to multiple positions.  The example design does not
     account for this, and may indicate errors even though data is being received
     correctly.

   - In the case of Clock correction, the GTP wrapper in the Example design is
     configured correctly but the BRAM data does not have embedded
     Clock-correction characters.

   - In ES silicon, the logic added to make TX timing more reliable, timing
     closure at fabric rates of 312.5 MHz and higher may require significant
     effort.  For best results, use a 16 or 20 bit interface for line rates
     higher than 1.25 Gbps.

   - RX buffer bypass in Oversampling mode is not supported.

   - This release has been tested with v8.8 and v8.9 of synplify

   The most recent information, including known issues, workarounds, and
   resolutions for this version is provided in the release notes Answer Record
   for the ISE 9.2i IP Update at

   http://www.xilinx.com/xlnx/xil_ans_display.jsp?getPagePath=29185


5. TECHNICAL SUPPORT

   To obtain technical support, create a WebCase at www.xilinx.com/support.
   Questions are routed to a team with expertise using this product.

   Xilinx provides technical support for use of this product when used
   according to the guidelines described in the core documentation, and
   cannot guarantee timing, functionality, or support of this product for
   designs that do not follow specified guidelines.


6. CORE RELEASE HISTORY

Date        By            Version      Description
================================================================================
10/10/2007  Xilinx, Inc.  1.7          Extended lxt package support
08/15/2007  Xilinx, Inc.  1.6          9.2i support
05/17/2007  Xilinx, Inc.  1.5          CPRI and OBSAI support
03/01/2007  Xilinx, Inc.  1.4          Extensive new features
11/30/2006  Xilinx, Inc.  1.3          Bug fixes
10/10/2006  Xilinx, Inc.  1.2          New protocol support
02/10/2004  Xilinx, Inc.  1.1          Initial release
================================================================================


(c) 2007 Xilinx, Inc. All Rights Reserved.


XILINX, the Xilinx logo, and other designated brands included herein are
trademarks of Xilinx, Inc. All other trademarks are the property of their
respective owners.

Xilinx is disclosing this user guide, manual, release note, and/or
specification (the Documentation) to you solely for use in the development
of designs to operate with Xilinx hardware devices. You may not reproduce,
distribute, republish, download, display, post, or transmit the Documentation
in any form or by any means including, but not limited to, electronic,
mechanical, photocopying, recording, or otherwise, without the prior written
consent of Xilinx. Xilinx expressly disclaims any liability arising out of
your use of the Documentation.  Xilinx reserves the right, at its sole
discretion, to change the Documentation without notice at any time. Xilinx
assumes no obligation to correct any errors contained in the Documentation, or
to advise you of any corrections or updates. Xilinx expressly disclaims any
liability in connection with technical support or assistance that may be
provided to you in connection with the information. THE DOCUMENTATION IS
DISCLOSED TO YOU AS-IS WITH NO WARRANTY OF ANY KIND. XILINX MAKES NO
OTHER WARRANTIES, WHETHER EXPRESS, IMPLIED, OR STATUTORY, REGARDING THE
DOCUMENTATION, INCLUDING ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
PARTICULAR PURPOSE, OR NONINFRINGEMENT OF THIRD-PARTY RIGHTS. IN NO EVENT
WILL XILINX BE LIABLE FOR ANY CONSEQUENTIAL, INDIRECT, EXEMPLARY, SPECIAL, OR
INCIDENTAL DAMAGES, INCLUDING ANY LOSS OF DATA OR LOST PROFITS, ARISING FROM
YOUR USE OF THE DOCUMENTATION.
