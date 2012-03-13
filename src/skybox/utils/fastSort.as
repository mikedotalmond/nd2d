package skybox.utils {
	
	/**
	 * Skyboy sort updated by Sociodox ( http://www.sociodox.com )
	 * fastSort, using typed native Number, int and uint
	 * Huge performance gain for all 3 type (2000%)
	 * Using Array.sort : 2000ms
	 * Using original fastSort : 400ms
	 * Using this typed fastSort : 20ms
	 * 2012/03/12
	 */
	
	/**
	 * fastSort by skyboy. February 26th 2011.
	 * Visit http://github.com/skyboy for documentation, updates
	 * and more free code.
	 *
	 *
	 * Copyright (c) 2010, skyboy
	 *    All rights reserved.
	 *
	 * Permission is hereby granted, free of charge, to any person
	 * obtaining a copy of this software and associated documentation
	 * files (the "Software"), to deal in the Software with
	 * restriction, with limitation the rights to use, copy, modify,
	 * merge, publish, distribute, sublicense copies of the Software,
	 * and to permit persons to whom the Software is furnished to do so,
	 * subject to the following conditions and limitations:
	 *
	 * ^ Attribution will be given to:
	 *  	skyboy, http://www.kongregate.com/accounts/skyboy;
	 *  	http://github.com/skyboy; http://skybov.deviantart.com
	 *
	 * ^ Redistributions of source code must retain the above copyright notice,
	 * this list of conditions and the following disclaimer in all copies or
	 * substantial portions of the Software.
	 *
	 * ^ Redistributions of modified source code must be marked as such, with
	 * the modifications marked and ducumented and the modifer's name clearly
	 * listed as having modified the source code.
	 *
	 * ^ Redistributions of source code may not add to, subtract from, or in
	 * any other way modify the above copyright notice, this list of conditions,
	 * or the following disclaimer for any reason.
	 *
	 * ^ Redistributions in binary form must reproduce the above copyright
	 * notice, this list of conditions and the following disclaimer in the
	 * documentation and/or other materials provided with the distribution.
	 *
	 * THE SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
	 * IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
	 * NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
	 * PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
	 * OR COPYRIGHT HOLDERS OR CONTRIBUTORS  BE LIABLE FOR ANY CLAIM, DIRECT,
	 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	 * OR OTHER LIABILITY,(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
	 * BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
	 * WHETHER AN ACTION OF IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
	 * NEGLIGENCE OR OTHERWISE) ARISING FROM, OUT OF, IN CONNECTION OR
	 * IN ANY OTHER WAY OUT OF THE USE OF OR OTHER DEALINGS WITH THIS
	 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	 */

	/**
	 * ...
	 * @author skyboy
	 */
	/**
	 * fastSort(*, uint);
	 * fastSort(*, String, uint);
	 *
	 * fastSort(vectorRef, "z", Array.NUMERIC);
	 * @param	*: input	The object to be sorted. Either an Array, Vector, or any Object (or subclass of) that has a length property and numeric indicies
	 * @param	*: ...rest	The second parameter can either be options (pass in the same you would for Array's sort method) or a String to trigger sortOn functionality, the third should then be the options.
	 */
	public function fastSort(input:*, ...rest):void {
		if (!input || !("length" in input) || !(input.length is int)) return;
		
		sortVec.length = 0;
		sortVec.length = input.length as uint;
		
		if (rest[0] is String) {
			if (!(rest[1] is Number)) rest[1] = 0;
			if (input is Array) {
				sortOnArray(input, rest[0], rest[1]);
			} else if (input is Vector.<Number>) {
				sortVecNumber.length = 0;
				sortVecNumber.length = input.length as uint;				
				sortOnVectorNumber(input, rest[0], rest[1]);
			} else if (input is Vector.<int>) {
				sortVecInt.length = 0;
				sortVecInt.length = input.length as uint;				
				sortOnVectorInt(input, rest[0], rest[1]);			
			} else if (input is Vector.<uint>) {
				sortVecUint.length = 0;
				sortVecUint.length = input.length as uint;				
				sortOnVectorUint(input, rest[0], rest[1]);					
			} else if (input is Vector.<*>) {
				sortOn(input, rest[0], rest[1]);
			} else {
				sortOnObject(input, rest[0], rest[1]);
			}
		} else {
			if (!(rest[0] is Number)) rest[0] = 0;
			if (input is Array) {
				sortArray(input, rest[0]);
			} else if (input is Vector.<Number> ) {
				sortVecNumber.length = 0;
				sortVecNumber.length = input.length as uint;	
				sortVectorNumber(input, rest[0]);
			} else if (input is Vector.<int> ) {
				sortVecInt.length = 0;
				sortVecInt.length = input.length as uint;	
				sortVectorInt(input, rest[0]);	
			} else if (input is Vector.<uint> ) {
				sortVecUint.length = 0;
				sortVecUint.length = input.length as uint;	
				sortVectorUint(input, rest[0]);					
			} else if (input is Vector.<*>) {
				sort(input, rest[0]);
			} else {
				sortObject(input, rest[0]);
			}
		}
	}
}

internal const NUMERIC:uint = Array.NUMERIC;
internal const DESCENDING:uint = Array.DESCENDING;
internal const CASEINSENSITIVE:uint = Array.CASEINSENSITIVE;
internal const sortVec:Vector.<*> = new Vector.<*>(0xFFFF); // reserve a large amount of space in memory for growth when sorting.
internal const sortVecNumber:Vector.<Number> = new Vector.<Number>(0); // reserve a large amount of space in memory for growth when sorting.
internal const sortVecInt:Vector.<int> = new Vector.<int>(0); // reserve a large amount of space in memory for growth when sorting.
internal const sortVecUint:Vector.<uint> = new Vector.<uint>(0); // reserve a large amount of space in memory for growth when sorting.

internal function quickSort(input:Vector.<*>, left:uint, right:uint, d:uint):void {
	if (right >= input.length) right = input.length - 1;
	if (left >= right) return;
	var j:uint = right, i:uint = left;
	var size:uint = right - left;
	var pivotPoint:* = input[(right + left) >>> 1], t:*;
	do {
		if (size < 9) {
			pivotPoint = input[left];
			do {
				do {
					++left;
					if (input[left] < pivotPoint) {
						pivotPoint = input[left];
						do { // this section can be improved.
							input[left--] = input[left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
				pivotPoint = input[left];
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do { --right; } while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do { ++left; } while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left == right) {
				if (input[left] < pivotPoint) ++left;
				else if (input[right] > pivotPoint) --right;
			}
			if (i < right) {
				quickSort(input, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}

internal function quickSortOn(input:Vector.<*>, sInput:Vector.<*>, left:uint, right:uint, d:uint):void {
	var j:uint = right >= input.length ? right = input.length - 1 : right;
	if (left >= right) return;
	var i:uint = left;
	var size:uint = right - left;
	var pivotPoint:* = input[(right + left) >>> 1], t:*;
	do {
		if (size < 9) {
			do {
				pivotPoint = input[left];
				do {
					++left;
					if (pivotPoint > input[left]) {
						pivotPoint = input[left];
						t = sInput[left];
						do {
							input[left] = input[left - 1];
							sInput[left] = sInput[--left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
						sInput[left] = t;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do {
				--right;
			} while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do {
				++left;
			} while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				t = sInput[left];
				sInput[left] = sInput[right];
				sInput[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left == right) {
				if (input[right] > pivotPoint) --right;
				else if (input[left] < pivotPoint) ++left;
				else ++left, --right;
			}
			if (i < right) {
				quickSortOn(input, sInput, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}

internal function quickSortArray(input:Array, left:uint, right:uint, d:uint):void {
	if (right >= input.length) right = input.length - 1;
	if (left >= right) return;
	var j:uint = right, i:uint = left;
	var size:uint = right - left;
	var pivotPoint:* = input[(right + left) >>> 1], t:*;
	do {
		if (size < 9) {
			pivotPoint = input[left];
			do {
				do {
					++left;
					if (input[left] < pivotPoint) {
						pivotPoint = input[left];
						do { // this section can be improved.
							input[left--] = input[left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
				pivotPoint = input[left];
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do { --right; } while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do { ++left; } while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left == right) {
				if (input[left] < pivotPoint) ++left;
				else if (input[right] > pivotPoint) --right;
			}
			if (i < right) {
				quickSortArray(input, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}

internal function quickSortOnArray(input:Vector.<*>, sInput:Array, left:uint, right:uint, d:uint):void {
	var j:uint = right >= input.length ? right = input.length - 1 : right;
	if (left >= right) return;
	var i:uint = left;
	var size:uint = right - left;
	var pivotPoint:* = input[(right + left) >>> 1], t:*;
	do {
		if (size < 9) {
			do {
				pivotPoint = input[left];
				do {
					++left;
					if (pivotPoint > input[left]) {
						pivotPoint = input[left];
						t = sInput[left];
						do {
							input[left] = input[left - 1];
							sInput[left] = sInput[--left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
						sInput[left] = t;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do {
				--right;
			} while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do {
				++left;
			} while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				t = sInput[left];
				sInput[left] = sInput[right];
				sInput[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left == right) {
				if (input[right] > pivotPoint) --right;
				else if (input[left] < pivotPoint) ++left;
				else ++left, --right;
			}
			if (i < right) {
				quickSortOnArray(input, sInput, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}

internal function quickSortObject(input:*, left:uint, right:uint, d:uint):void {
	if (right >= input.length) right = input.length - 1;
	if (left >= right) return;
	var j:uint = right, i:uint = left;
	var size:uint = right - left;
	var pivotPoint:* = input[(right + left) >>> 1], t:*;
	do {
		if (size < 9) {
			pivotPoint = input[left];
			do {
				do {
					++left;
					if (input[left] < pivotPoint) {
						pivotPoint = input[left];
						do { // this section can be improved.
							input[left--] = input[left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
				pivotPoint = input[left];
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do { --right; } while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do { ++left; } while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left == right) {
				if (input[left] < pivotPoint) ++left;
				else if (input[right] > pivotPoint) --right;
			}
			if (i < right) {
				quickSortObject(input, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}

internal function quickSortOnObject(input:Vector.<*>, sInput:*, left:uint, right:uint, d:uint):void {
	var j:uint = right >= input.length ? right = input.length - 1 : right;
	if (left >= right) return;
	var i:uint = left;
	var size:uint = right - left;
	var pivotPoint:* = input[(right + left) >>> 1], t:*;
	do {
		if (size < 9) {
			do {
				pivotPoint = input[left];
				do {
					++left;
					if (pivotPoint > input[left]) {
						pivotPoint = input[left];
						t = sInput[left];
						do {
							input[left] = input[left - 1];
							sInput[left] = sInput[--left];
						} while (left > i && pivotPoint < input[left]);
						input[left] = pivotPoint;
						sInput[left] = t;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[right] > pivotPoint) do {
				--right;
			} while (input[right] > pivotPoint);
			if (input[left] < pivotPoint) do {
				++left;
			} while (input[left] < pivotPoint);
			if (left < right) {
				t = input[left];
				input[left] = input[right];
				input[right] = t;
				t = sInput[left];
				sInput[left] = sInput[right];
				sInput[right] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left == right) {
				if (input[right] > pivotPoint) --right;
				else if (input[left] < pivotPoint) ++left;
				else ++left, --right;
			}
			if (i < right) {
				quickSortOnObject(input, sInput, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[(right + left) >>> 1];
		size = right - left;
		++d;
	} while (true);
}
internal function sort(input:Vector.<*>, options:uint):void {
	var n:uint = input.length;
	if (n < 2) return;
	var q:uint, left:uint, right:uint = n;
	var t:*;
	while (q != right) {
		t = input[q];
		if (t === undefined) {
			--right;
			input[q] = input[right];
			input[right] = undefined;
		} else if (t === null) {
			input[q] = input[left];
			input[left] = null;
			++left;
			++q;
		} else ++q;
	}
	if (right > left) {
		q = left;
		while (q < right) {
			t = input[q];
			if (t != t) {
				--right;
				input[q] = input[right];
				input[right] = NaN;
			} else ++q;
		}
		if (--right) {
			if (uint(right - 1) > left) {
				if (options == NUMERIC) {
					quickSort(input, left, right, 0);
				} else {
					var tempVec:Vector.<*> = sortVec;
					q = right;
					if (!(options & NUMERIC)) if (options & CASEINSENSITIVE) {
						tempVec[q] = String(input[q]).toLowerCase();
						while (q-- > left) tempVec[q] = String(input[q]).toLowerCase();
					} else {
						tempVec[q] = String(input[q]);
						while (q-- > left) tempVec[q] = String(input[q]);
					}
					quickSortOn(tempVec, input, left, right, 0);
				}
			}
		}
	}
	if (options & DESCENDING) {
		var i:uint = 0;
		while (n < i) {
			t = input[i];
			input[i++] = input[--n];
			input[n] = t;
		}
	}
}

internal function sortOn(input:Vector.<*>, name:String, options:uint):void {
	var n:uint = input.length;
	if (n < 2) return;
	var tempVec:Vector.<*> = sortVec, i:uint = n, t:*, j:uint = i;
	var left:uint, right:uint = i;
	while (j--) {
		t = input[j];
		t = name in t ? t[name] : t;
		if (t === null) {
			t = input[j];
			input[j] = input[left];
			input[left] = t;
			tempVec[left++] = null;
			++j;
		} else if (t === undefined) {
			if (--i != --right) {
				tempVec[i] = tempVec[right];
				tempVec[right] = undefined;
				t = input[right];
				input[right] = input[j];
				input[j] = t;
			}
		} else tempVec[--i] = t;
		if (j == left) break;
	}
	if (right > left) {
		j = right;
		while (--j > left) {
			t = tempVec[j];
			if (t != t) {
				if (j != --right) {
					tempVec[j] = tempVec[right];
					tempVec[right] = NaN;
					t = input[right];
					input[right] = input[j];
					input[j] = t;
				}
			}
		}
		if (--right) {
			if (uint(right - 1) > left) {
				if (!(options & NUMERIC)) {
					i = right;
					if (options & CASEINSENSITIVE) {
						tempVec[i] = String(tempVec[i]).toUpperCase();
						while (i-- > left) tempVec[i] = String(tempVec[i]).toUpperCase();
					} else {
						tempVec[i] = String(tempVec[i]);
						while (i-- > left) tempVec[i] = String(tempVec[i]);
					}
				}
				quickSortOn(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & DESCENDING) {
		i = 0;
		while (n != i) {
			t = input[i];
			input[i++] = input[--n];
			input[n] = t;
		}
	}
}

internal function sortArray(input:Array, options:uint):void {
	var n:uint = input.length;
	if (n < 2) return;
	var q:uint, left:uint, right:uint = n;
	var t:*;
	while (q != right) {
		t = input[q];
		if (t === undefined) {
			--right;
			input[q] = input[right];
			input[right] = undefined;
		} else if (t === null) {
			input[q] = input[left];
			input[left] = null;
			++left;
			++q;
		} else ++q;
	}
	if (right > left) {
		q = left;
		while (q < right) {
			t = input[q];
			if (t != t) {
				--right;
				input[q] = input[right];
				input[right] = NaN;
			} else ++q;
		}
		if (--right) {
			if (uint(right - 1) > left) {
				if (options == NUMERIC) {
					quickSortArray(input, left, right, 0);
				} else {
					var tempVec:Vector.<*> = sortVec;
					q = right;
					if (!(options & NUMERIC)) if (options & CASEINSENSITIVE) {
						tempVec[q] = String(input[q]).toLowerCase();
						while (q-- > left) tempVec[q] = String(input[q]).toLowerCase();
					} else {
						tempVec[q] = String(input[q]);
						while (q-- > left) tempVec[q] = String(input[q]);
					}
					quickSortOnArray(tempVec, input, left, right, 0);
				}
			}
		}
	}
	if (options & DESCENDING) {
		var i:uint = 0;
		while (n < i) {
			t = input[i];
			input[i++] = input[--n];
			input[n] = t;
		}
	}
}

internal function sortOnArray(input:Array, name:String, options:uint):void {
	var n:uint = input.length;
	if (n < 2) return;
	var tempVec:Vector.<*> = sortVec, i:uint = n, t:*, j:uint = i;
	var left:uint, right:uint = i;
	while (j--) {
		t = input[j];
		t = name in t ? t[name] : t;
		if (t === null) {
			t = input[j];
			input[j] = input[left];
			input[left] = t;
			tempVec[left++] = null;
			++j;
		} else if (t === undefined) {
			if (--i != --right) {
				tempVec[i] = tempVec[right];
				tempVec[right] = undefined;
				t = input[right];
				input[right] = input[j];
				input[j] = t;
			}
		} else tempVec[--i] = t;
		if (j == left) break;
	}
	if (right > left) {
		j = right;
		while (--j > left) {
			t = tempVec[j];
			if (t != t) {
				if (j != --right) {
					tempVec[j] = tempVec[right];
					tempVec[right] = NaN;
					t = input[right];
					input[right] = input[j];
					input[j] = t;
				}
			}
		}
		if (--right) {
			if (uint(right - 1) > left) {
				if (!(options & NUMERIC)) {
					i = right;
					if (options & CASEINSENSITIVE) {
						tempVec[i] = String(tempVec[i]).toUpperCase();
						while (i-- > left) tempVec[i] = String(tempVec[i]).toUpperCase();
					} else {
						tempVec[i] = String(tempVec[i]);
						while (i-- > left) tempVec[i] = String(tempVec[i]);
					}
				}
				quickSortOnArray(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & DESCENDING) {
		i = 0;
		while (n < i) {
			t = input[i];
			input[i++] = input[--n];
			input[n] = t;
		}
	}
}

internal function sortObject(input:*, options:uint):void {
	var n:uint = input.length;
	if (n < 2) return;
	var q:uint, left:uint, right:uint = n;
	var t:*;
	while (q != right) {
		t = input[q];
		if (t === undefined) {
			--right;
			input[q] = input[right];
			input[right] = undefined;
		} else if (t === null) {
			input[q] = input[left];
			input[left] = null;
			++left;
			++q;
		} else ++q;
	}
	if (right > left) {
		q = left;
		while (q < right) {
			t = input[q];
			if (t != t) {
				--right;
				input[q] = input[right];
				input[right] = NaN;
			} else ++q;
		}
		if (--right) {
			if (uint(right - 1) > left) {
				if (options == NUMERIC) {
					quickSortObject(input, left, right, 0);
				} else {
					var tempVec:Vector.<*> = sortVec;
					q = right;
					if (!(options & NUMERIC)) if (options & CASEINSENSITIVE) {
						tempVec[q] = String(input[q]).toLowerCase();
						while (q-- > left) tempVec[q] = String(input[q]).toLowerCase();
					} else {
						tempVec[q] = String(input[q]);
						while (q-- > left) tempVec[q] = String(input[q]);
					}
					quickSortOnObject(tempVec, input, left, right, 0);
				}
			}
		}
	}
	if (options & DESCENDING) {
		var i:uint = 0;
		while (n < i) {
			t = input[i];
			input[i++] = input[--n];
			input[n] = t;
		}
	}
}

internal function sortOnObject(input:*, name:String, options:uint):void {
	var n:uint = input.length;
	if (n < 2) return;
	var tempVec:Vector.<*> = sortVec, i:uint = n, t:*, j:uint = i;
	var left:uint, right:uint = i;
	while (j--) {
		t = input[j];
		t = name in t ? t[name] : t;
		if (t === null) {
			t = input[j];
			input[j] = input[left];
			input[left] = t;
			tempVec[left++] = null;
			++j;
		} else if (t === undefined) {
			if (--i != --right) {
				tempVec[i] = tempVec[right];
				tempVec[right] = undefined;
				t = input[right];
				input[right] = input[j];
				input[j] = t;
			}
		} else tempVec[--i] = t;
		if (j == left) break;
	}
	if (right > left) {
		j = right;
		while (--j > left) {
			t = tempVec[j];
			if (t != t) {
				if (j != --right) {
					tempVec[j] = tempVec[right];
					tempVec[right] = NaN;
					t = input[right];
					input[right] = input[j];
					input[j] = t;
				}
			}
		}
		if (--right) {
			if (uint(right - 1) > left) {
				if (!(options & NUMERIC)) {
					i = right;
					if (options & CASEINSENSITIVE) {
						tempVec[i] = String(tempVec[i]).toUpperCase();
						while (i-- > left) tempVec[i] = String(tempVec[i]).toUpperCase();
					} else {
						tempVec[i] = String(tempVec[i]);
						while (i-- > left) tempVec[i] = String(tempVec[i]);
					}
				}
				quickSortOnObject(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & DESCENDING) {
		i = 0;
		while (n < i) {
			t = input[i];
			input[i++] = input[--n];
			input[n] = t;
		}
	}
}
	
internal function quickSortVectorNumber(input:Vector.<Number>, left:int, right:int, d:int):void {
	if (right >= input.length) right = input.length - 1;
	if (left >= right) return;
	var j:int = right, i:int = left;
	var size:int = right - left;
	var pivotPoint:Number = input[int((right + left) >>> 1)], t:Number;
	do {
		if (size < 9) {
			pivotPoint = input[int(left)];
			do {
				do {
					++left;
					if (input[int(left)] < pivotPoint) {
						pivotPoint = input[int(left)];
						do { // this section can be improved.
							input[int(left--)] = input[int(left)];
						} while (left > i && pivotPoint < input[int(left)]);
						input[int(left)] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
				pivotPoint = input[int(left)];
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[int(right)] > pivotPoint) do { --right; } while (input[int(right)] > pivotPoint);
			if (input[int(left)] < pivotPoint) do { ++left; } while (input[int(left)] < pivotPoint);
			if (left < right) {
				t = input[int(left)];
				input[int(left)] = input[int(right)];
				input[int(right)] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left == right) {
				if (input[int(left)] < pivotPoint) ++left;
				else if (input[int(right)] > pivotPoint) --right;
			}
			if (i < right) {
				quickSortVectorNumber(input, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[int((right + left) >>> 1)];
		size = right - left;
		++d;
	} while (true);
}

internal function quickSortOnVectorNumber(input:Vector.<Number>, sInput:Vector.<Number>, left:int, right:int, d:int):void {
	var j:int = 0;
	if (right >= input.length)
	{
		j = right = input.length - 1;
	}
	else
	{
		right
	}

	if (left >= right) return;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:Number = input[int((right + left) >>> 1)], t:Number;
	do {
		if (size < 9) {
			do {
				pivotPoint = input[int(left)];
				do {
					++left;
					if (pivotPoint > input[int(left)]) {
						pivotPoint = input[int(left)];
						t = sInput[int(left)];
						do {
							input[int(left)] = input[int(left - 1)];
							sInput[int(left)] = sInput[int(--left)];
						} while (left > i && pivotPoint < input[int(left)]);
						input[int(left)] = pivotPoint;
						sInput[int(left)] = t;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[int(right)] > pivotPoint) do {
				--right;
			} while (input[int(right)] > pivotPoint);
			if (input[int(left)] < pivotPoint) do {
				++left;
			} while (input[int(left)] < pivotPoint);
			if (left < right) {
				t = input[int(left)];
				input[int(left)] = input[int(right)];
				input[int(right)] = t;
				t = sInput[int(left)];
				sInput[int(left)] = sInput[int(right)];
				sInput[int(right)] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left == right) {
				if (input[int(right)] > pivotPoint) --right;
				else if (input[int(left)] < pivotPoint) ++left;
				else ++left, --right;
			}
			if (i < right) {
				quickSortOnVectorNumber(input, sInput, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[int((right + left) >>> 1)];
		size = right - left;
		++d;
	} while (true);
}
internal function sortVectorNumber(input:Vector.<Number>, options:int):void {
	var n:int = input.length;
	if (n < 2) return;
	var q:int, left:int, right:int = n;
	var t:Number;
	q = right;

	if (right > left) {
		q = left;
		while (q < right) {
			t = input[int(q)];
			if (t != t) {
				--right;
				input[int(q)] = input[int(right)];
				input[int(right)] = NaN;
			} else ++q;
		}
		if (--right) {
			if (int(right - 1) > left) {
				quickSortVectorNumber(input, left, right, 0);
			}
		}
	}
	if (options & Array.DESCENDING) {
		var i:int = 0;
		while (n < i) {
			t = input[int(i)];
			input[int(i++)] = input[int(--n)];
			input[int(n)] = t;
		}
	}
}

internal function sortOnVectorNumber(input:Vector.<Number>, name:String, options:int):void {
	var n:int = input.length;
	if (n < 2) return;
	var tempVec:Vector.<Number> = sortVecNumber, i:int = n, t:Number, j:int = i;
	var left:int, right:int = i;
	while (j--) {
		t = input[int(j)];
		t = name in t ? t[name] : t;
		tempVec[int(--i)] = t;
		if (j == left) break;
	}
	if (right > left) {
		j = right;
		while (--j > left) {
			t = tempVec[int(j)];
			if (t != t) {
				if (j != --right) {
					tempVec[int(j)] = tempVec[int(right)];
					tempVec[int(right)] = NaN;
					t = input[int(right)];
					input[int(right)] = input[int(j)];
					input[int(j)] = t;
				}
			}
		}
		if (--right) {
			if (int(right - 1) > left) {
				quickSortOnVectorNumber(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & Array.DESCENDING) {
		i = 0;
		while (n != i) {
			t = input[int(i)];
			input[int(i++)] = input[int(--n)];
			input[int(n)] = t;
		}
	}	
}


internal function quickSortVectorInt(input:Vector.<int>, left:int, right:int, d:int):void {
	if (right >= input.length) right = input.length - 1;
	if (left >= right) return;
	var j:int = right, i:int = left;
	var size:int = right - left;
	var pivotPoint:int = input[int((right + left) >>> 1)], t:int;
	do {
		if (size < 9) {
			pivotPoint = input[int(left)];
			do {
				do {
					++left;
					if (input[int(left)] < pivotPoint) {
						pivotPoint = input[int(left)];
						do { // this section can be improved.
							input[int(left--)] = input[int(left)];
						} while (left > i && pivotPoint < input[int(left)]);
						input[int(left)] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
				pivotPoint = input[int(left)];
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[int(right)] > pivotPoint) do { --right; } while (input[int(right)] > pivotPoint);
			if (input[int(left)] < pivotPoint) do { ++left; } while (input[int(left)] < pivotPoint);
			if (left < right) {
				t = input[int(left)];
				input[int(left)] = input[int(right)];
				input[int(right)] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left == right) {
				if (input[int(left)] < pivotPoint) ++left;
				else if (input[int(right)] > pivotPoint) --right;
			}
			if (i < right) {
				quickSortVectorInt(input, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[int((right + left) >>> 1)];
		size = right - left;
		++d;
	} while (true);
}

internal function quickSortOnVectorInt(input:Vector.<int>, sInput:Vector.<int>, left:int, right:int, d:int):void {
	var j:int = 0;
	if (right >= input.length)
	{
		j = right = input.length - 1;
	}
	else
	{
		right
	}

	if (left >= right) return;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:int = input[int((right + left) >>> 1)], t:int;
	do {
		if (size < 9) {
			do {
				pivotPoint = input[int(left)];
				do {
					++left;
					if (pivotPoint > input[int(left)]) {
						pivotPoint = input[int(left)];
						t = sInput[int(left)];
						do {
							input[int(left)] = input[int(left - 1)];
							sInput[int(left)] = sInput[int(--left)];
						} while (left > i && pivotPoint < input[int(left)]);
						input[int(left)] = pivotPoint;
						sInput[int(left)] = t;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[int(right)] > pivotPoint) do {
				--right;
			} while (input[int(right)] > pivotPoint);
			if (input[int(left)] < pivotPoint) do {
				++left;
			} while (input[int(left)] < pivotPoint);
			if (left < right) {
				t = input[int(left)];
				input[int(left)] = input[int(right)];
				input[int(right)] = t;
				t = sInput[int(left)];
				sInput[int(left)] = sInput[int(right)];
				sInput[int(right)] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left == right) {
				if (input[int(right)] > pivotPoint) --right;
				else if (input[int(left)] < pivotPoint) ++left;
				else ++left, --right;
			}
			if (i < right) {
				quickSortOnVectorInt(input, sInput, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[int((right + left) >>> 1)];
		size = right - left;
		++d;
	} while (true);
}

internal function sortVectorInt(input:Vector.<int>, options:int):void {
	var n:int = input.length;
	if (n < 2) return;
	var q:int, left:int, right:int = n;
	var t:int;
	q = right;

	if (right > left) {
		q = left;
		while (q < right) {
			t = input[int(q)];
			if (t != t) {
				--right;
				input[int(q)] = input[int(right)];
				input[int(right)] = NaN;
			} else ++q;
		}
		if (--right) {
			if (int(right - 1) > left) {
				quickSortVectorInt(input, left, right, 0);
			}
		}
	}
	if (options & Array.DESCENDING) {
		var i:int = 0;
		while (n < i) {
			t = input[int(i)];
			input[int(i++)] = input[int(--n)];
			input[int(n)] = t;
		}
	}
}
	
internal function sortOnVectorInt(input:Vector.<int>, name:String, options:int):void {
	var n:int = input.length;
	if (n < 2) return;
	var tempVec:Vector.<int> = sortVecInt, i:int = n, t:int, j:int = i;
	var left:int, right:int = i;
	while (j--) {
		t = input[int(j)];
		t = name in t ? t[name] : t;
		tempVec[int(--i)] = t;
		if (j == left) break;
	}
	if (right > left) {
		j = right;
		while (--j > left) {
			t = tempVec[int(j)];
			if (t != t) {
				if (j != --right) {
					tempVec[int(j)] = tempVec[int(right)];
					tempVec[int(right)] = NaN;
					t = input[int(right)];
					input[int(right)] = input[int(j)];
					input[int(j)] = t;
				}
			}
		}
		if (--right) {
			if (int(right - 1) > left) {
				quickSortOnVectorInt(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & Array.DESCENDING) {
		i = 0;
		while (n != i) {
			t = input[int(i)];
			input[int(i++)] = input[int(--n)];
			input[int(n)] = t;
		}
	}	
}


internal function quickSortVectorUint(input:Vector.<uint>, left:int, right:int, d:int):void {
	if (right >= input.length) right = input.length - 1;
	if (left >= right) return;
	var j:int = right, i:int = left;
	var size:int = right - left;
	var pivotPoint:uint = input[int((right + left) >>> 1)], t:uint;
	do {
		if (size < 9) {
			pivotPoint = input[int(left)];
			do {
				do {
					++left;
					if (input[int(left)] < pivotPoint) {
						pivotPoint = input[int(left)];
						do { // this section can be improved.
							input[int(left--)] = input[int(left)];
						} while (left > i && pivotPoint < input[int(left)]);
						input[int(left)] = pivotPoint;
					}
				} while (left < right);
				++i;
				left = i;
				pivotPoint = input[int(left)];
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[int(right)] > pivotPoint) do { --right; } while (input[int(right)] > pivotPoint);
			if (input[int(left)] < pivotPoint) do { ++left; } while (input[int(left)] < pivotPoint);
			if (left < right) {
				t = input[int(left)];
				input[int(left)] = input[int(right)];
				input[int(right)] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left == right) {
				if (input[int(left)] < pivotPoint) ++left;
				else if (input[int(right)] > pivotPoint) --right;
			}
			if (i < right) {
				quickSortVectorUint(input, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[int((right + left) >>> 1)];
		size = right - left;
		++d;
	} while (true);
}

internal function quickSortOnVectorUint(input:Vector.<uint>, sInput:Vector.<uint>, left:int, right:int, d:int):void {
	var j:int = 0;
	if (right >= input.length)
	{
		j = right = input.length - 1;
	}
	else
	{
		right
	}

	if (left >= right) return;
	var i:int = left;
	var size:int = right - left;
	var pivotPoint:uint = input[int((right + left) >>> 1)], t:uint;
	do {
		if (size < 9) {
			do {
				pivotPoint = input[int(left)];
				do {
					++left;
					if (pivotPoint > input[int(left)]) {
						pivotPoint = input[int(left)];
						t = sInput[int(left)];
						do {
							input[int(left)] = input[int(left - 1)];
							sInput[int(left)] = sInput[int(--left)];
						} while (left > i && pivotPoint < input[int(left)]);
						input[int(left)] = pivotPoint;
						sInput[int(left)] = t;
					}
				} while (left < right);
				++i;
				left = i;
			} while (i < right);
			return;
		}
		while (left < right) {
			if (input[int(right)] > pivotPoint) do {
				--right;
			} while (input[int(right)] > pivotPoint);
			if (input[int(left)] < pivotPoint) do {
				++left;
			} while (input[int(left)] < pivotPoint);
			if (left < right) {
				t = input[int(left)];
				input[int(left)] = input[int(right)];
				input[int(right)] = t;
				t = sInput[int(left)];
				sInput[int(left)] = sInput[int(right)];
				sInput[int(right)] = t;
				++left, --right;
			}
		}
		if (right) {
			if (left == right) {
				if (input[int(right)] > pivotPoint) --right;
				else if (input[int(left)] < pivotPoint) ++left;
				else ++left, --right;
			}
			if (i < right) {
				quickSortOnVectorUint(input, sInput, i, right, d + 1);
			}
		} else if (!left) left = 1;
		if (j <= left) return;
		i = left;
		right = j;
		pivotPoint = input[int((right + left) >>> 1)];
		size = right - left;
		++d;
	} while (true);
}

internal function sortVectorUint(input:Vector.<uint>, options:int):void {
	var n:int = input.length;
	if (n < 2) return;
	var q:int, left:int, right:int = n;
	var t:uint;
	q = right;

	if (right > left) {
		q = left;
		while (q < right) {
			t = input[int(q)];
			if (t != t) {
				--right;
				input[int(q)] = input[int(right)];
				input[int(right)] = NaN;
			} else ++q;
		}
		if (--right) {
			if (int(right - 1) > left) {
				quickSortVectorUint(input, left, right, 0);
			}
		}
	}
	if (options & Array.DESCENDING) {
		var i:int = 0;
		while (n < i) {
			t = input[int(i)];
			input[int(i++)] = input[int(--n)];
			input[int(n)] = t;
		}
	}
}

internal function sortOnVectorUint(input:Vector.<uint>, name:String, options:int):void {
	var n:int = input.length;
	if (n < 2) return;
	var tempVec:Vector.<uint> = sortVecUint, i:int = n, t:uint, j:int = i;
	var left:int, right:int = i;
	while (j--) {
		t = input[int(j)];
		t = name in t ? t[name] : t;
		tempVec[int(--i)] = t;
		if (j == left) break;
	}
	if (right > left) {
		j = right;
		while (--j > left) {
			t = tempVec[int(j)];
			if (t != t) {
				if (j != --right) {
					tempVec[int(j)] = tempVec[int(right)];
					tempVec[int(right)] = NaN;
					t = input[int(right)];
					input[int(right)] = input[int(j)];
					input[int(j)] = t;
				}
			}
		}
		if (--right) {
			if (int(right - 1) > left) {
				quickSortOnVectorUint(tempVec, input, left, right, 0);
			}
		}
	}
	if (options & Array.DESCENDING) {
		i = 0;
		while (n != i) {
			t = input[int(i)];
			input[int(i++)] = input[int(--n)];
			input[int(n)] = t;
		}
	}	
}