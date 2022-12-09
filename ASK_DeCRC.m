function [CRC_flag,out_data] = ASK_DeCRC(input_data, crc_num)

    % length of input_data
    input_num = length(input_data);

    % 1 x crc_num, row vectors, filled with 0
    crcBit = zeros(1, crc_num);
    regOut = zeros(1, crc_num);        
    oldCRC = zeros(1, crc_num);         

    % the given CRC checksum in input_data
    oldCRC_rev = (input_data(1, input_num - crc_num + 1 : input_num));

    % generate polynomial
    % gCRC24(D) = D24 + D23 + D6 + D5 + D + 1
    % gCRC16(D) = D16 + D12 + D5 + 1
    % gCRC12(D) = D12 + D11 + D3 + D2 + D + 1
    gCRC24 = [1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 1 1];
    gCRC16 = [1 0 0 0 1 0 0 0 0 0 0 1 0 0 0 0 1];
    gCRC12 = [1 1 0 0 0 0 0 0 0 1 1 1 1];

    % CRC case switch
    switch crc_num
        case 24
            g = gCRC24;
        case 16
            g = gCRC16;
        case 12
            g = gCRC12;
    end

    % CRC checksum verification
    % raw data in input_data
    raw = input_data(1, 1 : input_num - crc_num);
    out_data = raw;

    % move raw data(raw) left by the degree of CRC
    % then divide it with generate polynomial(g), get quotient(q) and remainder(r)
    % q = conv([raw zeros(1, crc_num)], g);
    [q, r] = deconv([raw zeros(1, crc_num)], g);

    % extract the ending bits, and mod it by 2 -> CRC checksum
    r_length = length(r);
    % crcBit = deconv(q, g);
    crcBit = mod(r(1, r_length - crc_num + 1 : r_length), 2);

    % turn the calculated remainder around
    crcBit_rev = fliplr(crcBit);

    % check if there is any different CRC bit
    err = bitxor(crcBit_rev, oldCRC_rev)

    % if the magnitude of the err vector is larger than zero, the integrity of the data frame is broken
    % CRC_flag -> intact
    % !CRC_flag -> broken
    if (norm(err) == 0) 
        CRC_flag = 1;
    else
        CRC_flag = 0;

end
