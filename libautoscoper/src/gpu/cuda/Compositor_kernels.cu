// ----------------------------------
// Copyright (c) 2011, Brown University
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
// 
// (1) Redistributions of source code must retain the above copyright
// notice, this list of conditions and the following disclaimer.
// 
// (2) Redistributions in binary form must reproduce the above copyright
// notice, this list of conditions and the following disclaimer in the
// documentation and/or other materials provided with the distribution.
// 
// (3) Neither the name of Brown University nor the names of its
// contributors may be used to endorse or promote products derived from
// this software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY BROWN UNIVERSITY “AS IS” WITH NO
// WARRANTIES OR REPRESENTATIONS OF ANY KIND WHATSOEVER EITHER EXPRESS OR
// IMPLIED, INCLUDING WITHOUT LIMITATION ANY WARRANTY OF DESIGN OR
// MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE, EACH OF WHICH ARE
// SPECIFICALLY DISCLAIMED, NOR ANY WARRANTY OR REPRESENTATIONS THAT THE
// SOFTWARE IS ERROR FREE OR THAT THE SOFTWARE WILL NOT INFRINGE ANY
// PATENT, COPYRIGHT, TRADEMARK, OR OTHER THIRD PARTY PROPRIETARY RIGHTS.
// IN NO EVENT SHALL BROWN UNIVERSITY BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS
// OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
// ON ANY THEORY OF LIABILITY OR CAUSE OF ACTION, WHETHER IN CONTRACT,
// STRICT LIABILITY, TORT, NEGLIGENCE OR OTHERWISE, ARISING IN ANY WAY
// OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
// SUCH DAMAGE. ANY RECIPIENT OR USER OF THIS SOFTWARE ACKNOWLEDGES THE
// FOREGOING, AND ACCEPTS ALL RISKS AND LIABILITIES THAT MAY ARISE FROM
// THEIR USE OF THE SOFTWARE.
// ----------------------------------

/// \file Compositor_kernels.cu
/// \author Andy Loomis

#include "Compositor_kernels.h"


// Define the cuda compositiing kernel
__global__
void composite_kernel(float* src1,
                      float* src2,
                      float* dest,
                      size_t width,
                      size_t height);


namespace xromm {
	namespace gpu {
void composite(float* src1,
               float* src2,
               float* dest,
               size_t width,
               size_t height)
{
    // Calculate the block and grid sizes.
    dim3 blockDim(16, 16);
    dim3 gridDim((width+blockDim.x-1)/blockDim.x,
                 (height+blockDim.y-1)/blockDim.y);
    
    // Call the kernel
    composite_kernel<<<gridDim, blockDim>>>(src1,src2,dest,width,height);
}

} // namespace gpu

} // namespace xromm

__global__
void composite_kernel(float* src1,
                      float* src2,
                      float* dest,
                      size_t width,
                      size_t height)
{
    int x = blockIdx.x*blockDim.x+threadIdx.x;
    int y = blockIdx.y*blockDim.y+threadIdx.y;

    if (x > width-1 || y > height-1) {
        return;
    }

    // src1 maps to orange and src2 to blue
    dest[3*(y*width+x)+0] = src1[y*width+x];
    dest[3*(y*width+x)+1] = src1[y*width+x]/2.0f+src2[y*width+x]/2.0f;
    dest[3*(y*width+x)+2] = src2[y*width+x];
}

