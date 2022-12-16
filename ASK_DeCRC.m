% Ref: https://www.mathworks.com/help/matlab/matlab_prog/perform-cyclic-redundancy-check.html
%      https://www.ghsi.de/pages/subpages/Online%20CRC%20Calculation/indexDetails.php

function [CRC_flag,out_data] = ASK_DeCRC(input_data, crc_num)
% input_data: the whole data, raw message appended by the reverse of checksum, binary array
% crc_num:    the most significant index number of the chosen CRC generator polynomial
% CRC_flag:   indicates the integrity of dataframe, 1 -> intact / 0 -> compromised
% out_data:   the raw message in the data


    % length of input_data
    input_num = length(input_data);

    % % 1 x crc_num, row vectors, filled with 0
    % crcBit = zeros(1, crc_num);
    % regOut = zeros(1, crc_num);        
    oldCRC = zeros(1, crc_num);         

    % % the given CRC checksum in input_data
    % oldCRC_rev = (input_data(1, input_num - crc_num + 1 : input_num));

    % generator polynomial
    % gCRC24(D) = D24 + D23                                       + D6 + D5                 + D + 1
    % gCRC16(D) =                  D16 + D12                           + D5                     + 1
    % gCRC12(D) =                        D12 + D11                                + D3 + D2 + D + 1
    % gCRC8(D)  =                                        D8  + D7           + D4  + D3      + D + 1
    gCRC24 = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 1 1];
    gCRC16 =                 [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
    gCRC12 =                         [1 1 0 0 0 0 0 0 0 1 1 1 1];
    gCRC8  =                                 [1 1 0 0 1 1 0 1 1];

    % select CRC generator polynomial
    switch crc_num
        case 24
            g = gCRC24;
        case 16
            g = gCRC16;
        case 12
            g = gCRC12;
        case 8
            g = gCRC8;
    end

    % CRC checksum verification
    % Flip the reversed CRC checksum. 
    % Then divide the whole array with the generator polynomial. 
    % The data is intact if and only if the remainder is zero.

    % raw data in input_data
    raw = input_data(1 : input_num - crc_num);
    out_data = raw;

    % the CRC checksum appended in the data is flipped
    oldCRC_rev = input_data(input_num - crc_num : input_num);
    oldCRC     = fliplr(oldCRC_rev);

    % % move raw data(raw) left by the degree of CRC
    % reg = [raw zeros(1, crc_num)]

    % concatenate the raw message and the actual given CRC checksum
    reg = [raw oldCRC];

    % > Each step the polynomial divisor is aligned with the left-most 1 in the number. 
    % > Because the result of dividing by the four term polynomial has three bits. 
    for i = 1 : input_num - crc_num
        if (reg(i) > 0)
            reg(i : i + crc_num) = bitxor(reg(i : i + crc_num), g);
        end
    end
    
    % the remainder of the previous calculation 
    remainder = reg(input_num - crc_num + 1 : input_num);

    % % turn the calculated remainder around
    % crcBit_rev = fliplr(crcBit)

    % % check if there is any different CRC bit
    % err = bitxor(crcBit_rev, oldCRC_rev)

    % The remainder is expected to be zero. 
    % If the magnitude of the `remainder` vector is larger than zero, 
    % then the integrity of the data frame is broken. 

    % CRC_flag -> intact
    % !CRC_flag -> compromised
    if (norm(remainder) == 0) 
        CRC_flag = 1;
    else
        CRC_flag = 0;
    end

end
