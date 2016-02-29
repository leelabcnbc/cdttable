function good_channel_unit = get_good_channel_unit(recording_date)
    switch recording_date
        case 'demo_date'
            unit2 = [];
            unit1 = [32];
            unit0 = [30];
    end
    good_channel_unit = [[unit2, unit1, unit0];
    [2*ones(1,length(unit2)) ones(1,length(unit1)) zeros(1,length(unit0))]];        
end



