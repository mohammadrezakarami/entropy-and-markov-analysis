function ASCIIEntropyGUI
    % Create the main application window
    fig = uifigure('Name', 'ASCII Entropy Calculator', 'Position', [500, 300, 600, 500]);
    
    % Add a title label to the GUI
    uilabel(fig, 'Text', 'ASCII Entropy Calculator', ...
        'Position', [200, 450, 200, 30], 'FontSize', 14);
    
    % Add input field for the text
    uilabel(fig, 'Text', 'Enter Text:', ...
        'Position', [20, 400, 100, 20]); % Label for text input
    txtInput = uieditfield(fig, 'text', ...
        'Position', [20, 370, 560, 30]); % Editable field for user text input
    
    % Add input field for the order/grouping size
    uilabel(fig, 'Text', 'Order (Grouping size):', ...
        'Position', [20, 330, 130, 20]); % Label for grouping size input
    orderInput = uieditfield(fig, 'numeric', ...
        'Position', [160, 330, 50, 30], 'Value', 1, 'Limits', [1, Inf]); % Numeric input field for order
    
    % Add a button to trigger the calculation
    btnConvert = uibutton(fig, 'push', ...
        'Text', 'Calculate', ...
        'Position', [150, 290, 100, 30]); % Button for triggering calculation
    btnConvert.ButtonPushedFcn = @(~, ~) onCalculate(txtInput.Value, orderInput.Value); % Define button callback
    
    % Add labels to display the results of the calculation
    uilabel(fig, 'Text', 'Entropy Rate:', ...
        'Position', [20, 230, 100, 20]); % Label for entropy rate
    entropyRateLabel = uilabel(fig, 'Text', '', ...
        'Position', [130, 230, 200, 20]); % Display field for entropy rate

    uilabel(fig, 'Text', 'Avg Bits per Symbol:', ...
        'Position', [20, 190, 120, 20]); % Label for average bits
    avgBitsLabel = uilabel(fig, 'Text', '', ...
        'Position', [150, 190, 200, 20]); % Display field for average bits per symbol

    uilabel(fig, 'Text', 'Probability Distribution:', ...
        'Position', [20, 150, 150, 20]); % Label for probability distribution
    probDistLabel = uilabel(fig, 'Text', '', ...
        'Position', [20, 100, 360, 40], ...
        'HorizontalAlignment', 'left', 'WordWrap', 'on'); % Display area for probability distribution
    
    % Add a table to display detailed probabilities
    probTable = uitable(fig, ...
        'Position', [300, 20, 260, 240], ...
        'ColumnName', {'Word', 'Probability'}); % Table for word and probability data
    
    % Function to handle the calculation when the button is clicked
    function onCalculate(inputText, order)
        % Convert the input text to ASCII values
        asciiText = double(inputText);
        
        % Group ASCII values based on the specified order
        numGroups = floor(length(asciiText) / order); % Number of complete groups
        groupedText = [];
        for i = 1:numGroups
            % Combine ASCII values into a single number per group
            group = sum(asciiText((i-1)*order+1:i*order) .* 256.^(0:order-1));
            groupedText = [groupedText group]; 
        end
        
        % Calculate unique symbols and their frequencies
        [uniqueSymbols, ~, idx] = unique(groupedText, 'stable'); % Find unique groups
        counts = histc(idx, 1:numel(uniqueSymbols)); % Count occurrences of each group
        probs = counts / sum(counts); % Calculate probabilities
        
        % Sort the probabilities in descending order
        [sortedProbs, sortedIdx] = sort(probs, 'descend');
        sortedSymbols = uniqueSymbols(sortedIdx); % Reorder symbols based on probabilities

        % Format the probability distribution as a readable string
        probDistText = '';
        for i = 1:length(sortedSymbols)
            probDistText = [probDistText sprintf('Symbol: %d, Probability: %.4f\n', ...
                sortedSymbols(i), sortedProbs(i))];
        end
        probDistLabel.Text = probDistText; % Display the formatted probability distribution

        % Calculate entropy rate and average bits per symbol
        entropyRate = -sum(sortedProbs .* log2(sortedProbs)); % Shannon entropy formula
        avgBits = entropyRate / order; % Adjust for grouping size
        entropyRateLabel.Text = sprintf('%.4f', entropyRate); % Display entropy rate
        avgBitsLabel.Text = sprintf('%.4f', avgBits); % Display average bits per symbol

        % Convert each unique symbol back into its ASCII representation
        words = cell(length(sortedSymbols), 1);
        for i = 1:length(sortedSymbols)
            word = '';
            tempSymbol = sortedSymbols(i);
            for j = 1:order
                % Decode the grouped symbol back into individual ASCII characters
                word = [char(mod(floor(tempSymbol / 256^(j-1)), 256)) word];
            end
            words{i} = word;  
        end

        % Populate the table with decoded words and their probabilities
        probTable.Data = table(words(:), num2cell(sortedProbs(:)), ...
            'VariableNames', {'Word', 'Probability'});
    end
end
