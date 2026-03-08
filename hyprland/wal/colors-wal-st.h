const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#0d0505", /* black   */
  [1] = "#A35A6C", /* red     */
  [2] = "#C16A7F", /* green   */
  [3] = "#AD887C", /* yellow  */
  [4] = "#BC7B81", /* blue    */
  [5] = "#D0758A", /* magenta */
  [6] = "#E27C95", /* cyan    */
  [7] = "#c2c0c0", /* white   */

  /* 8 bright colors */
  [8]  = "#675555",  /* black   */
  [9]  = "#A35A6C",  /* red     */
  [10] = "#C16A7F", /* green   */
  [11] = "#AD887C", /* yellow  */
  [12] = "#BC7B81", /* blue    */
  [13] = "#D0758A", /* magenta */
  [14] = "#E27C95", /* cyan    */
  [15] = "#c2c0c0", /* white   */

  /* special colors */
  [256] = "#0d0505", /* background */
  [257] = "#c2c0c0", /* foreground */
  [258] = "#c2c0c0",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
