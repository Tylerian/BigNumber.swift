/**
 * Copyright Jairo Tylera, 2018 - Present
 *
 * Licensed under the MIT License, (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * https://opensource.org/licenses/MIT
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import CTomMath

extension mp_int
{
    internal init()
    {
        self = mp_int(used: 0, alloc: 0, sign: 0, dp: nil)
    }
}
