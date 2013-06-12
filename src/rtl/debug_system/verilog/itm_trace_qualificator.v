/**
 * This file is part of OpTiMSoC.
 *
 * OpTiMSoC is free hardware: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as
 * published by the Free Software Foundation, either version 3 of
 * the License, or (at your option) any later version.
 *
 * As the LGPL in general applies to software, the meaning of
 * "linking" is defined as using OpTiMSoC in your projects at
 * the external interfaces.
 *
 * OpTiMSoC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with OpTiMSoC. If not, see <http://www.gnu.org/licenses/>.
 *
 * =================================================================
 *
 * Submodule of the Instruction Trace Module (ITM): the trace qualificator
 *
 * (c) 2012 by the author(s)
 *
 * Author(s):
 *    Philipp Wagner, mail@philipp-wagner.com
 */

`include "dbg_config.vh"

module itm_trace_qualificator(/*AUTOARG*/
   // Outputs
   trace_enable, trigger_out,
   // Inputs
   clk, rst, trace_in, trigger_in, conf_mem_flat
   );

   parameter CONF_MEM_SIZE = 'hx;

   input clk;
   input rst;

   // trace data (uncompressed, before delay through ringbuffer)
   input [`DBG_TIMESTAMP_WIDTH+32-1:0] trace_in;

   // enable tracing?
   output trace_enable;

   // trigger interface
   input trigger_in;
   output trigger_out;

   input [16*CONF_MEM_SIZE-1:0] conf_mem_flat;

   // un-flatten conf_mem_flat to conf_mem
   wire [15:0] conf_mem [CONF_MEM_SIZE-1:0];
   generate
      genvar i;
      for (i = 0; i < CONF_MEM_SIZE; i = i + 1) begin : gen_conf_mem
         assign conf_mem[i] = conf_mem_flat[((i+1)*16)-1:i*16];
      end
   endgenerate

   wire trace_enable_undelayed;
   wire internal_trigger_enable;

   debug_data_sr
      #(.DATA_WIDTH(1))
      u_data_sr(.clk(clk),
                .rst(rst),
                .din(trace_enable_undelayed),
                .dout(internal_trigger_enable));

   assign trace_enable = internal_trigger_enable | trigger_in;

   // convenience signals: map config registers to named variables
   wire [31:0] conf_pc_lower, conf_pc_upper;
   assign conf_pc_lower = {conf_mem[2], conf_mem[3]};
   assign conf_pc_upper = {conf_mem[4], conf_mem[5]};

   // tracing is disabled if upper and lower bound are set to 0
   wire disable_tracing;
   assign disable_tracing = (conf_pc_lower == 0 && conf_pc_upper == 0);

   assign trace_enable_undelayed = !disable_tracing &&
                                   trace_in[31:0] >= conf_pc_lower &&
                                   trace_in[31:0] <= conf_pc_upper;
   assign trigger_out = trace_enable_undelayed;
endmodule