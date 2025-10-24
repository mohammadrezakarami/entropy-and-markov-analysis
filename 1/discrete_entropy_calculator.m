function discrete_entropy_calculator
    % Creating a graphical user interface (GUI) to calculate the entropy of a discrete variable
    
    % Creating a new window with a specified title and dimensions
    f = figure('Name', 'Discrete Entropy Calculator', 'Position', [300, 300, 600, 400]);

    % Adding a label to display the input "p(n) proportional to"
    uicontrol('Style', 'text', 'Position', [50, 300, 150, 20], 'String', 'p(n) proportional to:', 'HorizontalAlignment', 'left');
    % Adding a text field to receive the p(n) expression from the user
    inputP = uicontrol('Style', 'edit', 'Position', [220, 300, 150, 20], 'String', '1/(n^2+1)');
    
    % Adding a label to display the input prompt "Range of n:"
    uicontrol('Style', 'text', 'Position', [50, 250, 150, 20], 'String', 'Range of n:', 'HorizontalAlignment', 'left');
    % Adding a text field for entering the range of n
    inputRange = uicontrol('Style', 'edit', 'Position', [220, 250, 150, 20], 'String', '0,10');
    
    % Adding a label to display the entropy result
    uicontrol('Style', 'text', 'Position', [50, 200, 150, 20], 'String', 'Entropy =', 'HorizontalAlignment', 'left');
    % Adding a non-editable text field to display the calculated entropy value
    entropyText = uicontrol('Style', 'edit', 'Position', [220, 200, 150, 20], 'Enable', 'inactive', 'BackgroundColor', [0.9, 0.9, 0.9]);

    % Adding a button to trigger the entropy calculation
    calculateButton = uicontrol('Style', 'pushbutton', 'Position', [50, 150, 100, 30], 'String', 'Calculate', 'Callback', @calculateEntropy);

    % Creating an area for plotting the graph
    axesHandle = axes('Position', [0.5, 0.3, 0.4, 0.6]);

    % Defining a function to calculate entropy
    function calculateEntropy(~, ~)
      
        % Get the p(n) expression from the input field.
        pExpression = get(inputP, 'String');
        % Get the n range from the input field
        rangeStr = get(inputRange, 'String');
        
        % Convert the range string to numbers
        rangeParts = str2num(rangeStr); %#ok<ST2NM>
        if length(rangeParts) ~= 2
            % Display an error message if the range is invalid
            errordlg("The range of n should be in the format 'start,end'");
            return;
        end
        nStart = rangeParts(1); % Starting value of the range.
        nEnd = rangeParts(2); % Ending value of the range.
        
        % Convert the entered expression into an executable function
        try
            pFunc = str2func(['@(n) ' pExpression]);
        catch
            % Display an error message if the function is invalid
            errordlg('The expression entered for p(n) is not valid.');
            return;
        end
        
        % Calculate the values of n and p(n) for the specified range
        nValues = nStart:nEnd;
        pValues = arrayfun(pFunc, nValues); % Apply the p(n) function to the values of n
        pValues = pValues / sum(pValues); % Normalize the probability values

        % Calculate the entropy based on the formula
        entropy = -sum(pValues .* log2(pValues));
        % Display the calculated entropy value.
        set(entropyText, 'String', sprintf('%.6f', entropy));
        
        % Plot the probability distribution graph
        plot(axesHandle, nValues, pValues, '-o');
        xlabel(axesHandle, 'n'); % Label the x-axis
        ylabel(axesHandle, 'p(n)'); % Label the y-axis
        title(axesHandle, 'Probability Distribution'); % Title of the graph.
    end
end
