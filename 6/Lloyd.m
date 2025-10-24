function lloyd_algorithm_gui
    % This function creates a graphical user interface (GUI) to implement and
    % visualize the Lloyd algorithm. The user can input a PDF function, range,
    % and the number of quantization points, and the program will compute the
    % optimal quantization points and distortion.

    % Create the main window for the GUI
    fig = uifigure('Name', 'Lloyd Algorithm', 'Position', [100, 100, 600, 400]);

    % Add a title at the top of the GUI to describe the tool
    uilabel(fig, 'Text', 'Lloyd Algorithm', 'FontSize', 20, ...
        'FontWeight', 'bold', 'HorizontalAlignment', 'center', ...
        'Position', [150, 360, 300, 30]);

    % Input for the probability density function (PDF) as a string
    uilabel(fig, 'Text', 'Enter PDF function:', 'Position', [20, 300, 200, 22]);
    pdfInput = uieditfield(fig, 'text', 'Value', 'exp(-x.^2 / 2)', 'Position', [20, 270, 200, 22]);

    % Input for the range [a, b] of the PDF
    uilabel(fig, 'Text', 'Enter range [a, b]:', 'Position', [20, 230, 200, 22]);
    rangeInput = uieditfield(fig, 'text', 'Value', '[-10, 10]', 'Position', [20, 200, 200, 22]);

    % Input for the number of quantization points (how many points you want)
    uilabel(fig, 'Text', 'Number of quantization points:', 'Position', [20, 160, 200, 22]);
    pointsInput = uieditfield(fig, 'numeric', 'Value', 2, 'Position', [20, 130, 200, 22]);

    % A button for the user to click when ready to compute the results
    computeButton = uibutton(fig, 'Text', 'Compute Lloyd Algorithm', ...
        'Position', [20, 80, 200, 30], 'ButtonPushedFcn', @(btn, event)computeCallback);

    % A label and field to show the final distortion after computation
    uilabel(fig, 'Text', 'Optimum Distortion:', 'Position', [330, 300, 200, 22]);
    distortionOutput = uilabel(fig, 'Position', [330, 270, 200, 22], 'Text', '', 'FontSize', 12);

    % A label and text area to show the final quantization points
    uilabel(fig, 'Text', 'Quantization Points Table:', 'Position', [330, 230, 200, 22]);
    pointsOutput = uitextarea(fig, 'Editable', 'off', 'Position', [330, 100, 200, 120]);

    % This is the function that gets called when the "Compute" button is pressed
    function computeCallback
        try
            % Get the PDF function input from the user
            pdfStr = pdfInput.Value;

            % Parse the range input (e.g., convert '[a, b]' to a numeric array)
            rangeVals = str2num(rangeInput.Value); %#ok<ST2NM> 

            % Get the number of quantization points the user wants
            numPoints = pointsInput.Value;

            % Create a set of x-values evenly spaced in the specified range
            x = linspace(rangeVals(1), rangeVals(2), 5000);

            % Convert the user-entered PDF function string into a MATLAB function
            pdfFunc = str2func(['@(x)', pdfStr]);

            % Evaluate the PDF at the x-values and make sure it's non-negative
            pdfVals = pdfFunc(x);
            pdfVals(pdfVals < 0) = 0;

            % Normalize the PDF so its total area is 1 (necessary for probabilities)
            pdfVals = pdfVals / trapz(x, pdfVals);

            % Start with evenly spaced quantization points
            q = linspace(rangeVals(1), rangeVals(2), numPoints);

            % Set up the maximum iterations and a tolerance for when to stop
            maxIter = 500;
            tol = 1e-5;

            % Perform Lloyd's algorithm (iteratively improve the quantization points)
            for iter = 1:maxIter
                % Determine the boundaries between quantization regions
                boundaries = [-inf, (q(1:end-1) + q(2:end)) / 2, inf];

                % Initialize a new set of quantization points
                newQ = zeros(size(q));

                % Adjust each quantization point based on its region
                for i = 1:numPoints
                    % Get the x-values that belong to the current region
                    region = x(x > boundaries(i) & x <= boundaries(i+1));

                    % Get the PDF values in this region
                    pdfRegion = pdfVals(x > boundaries(i) & x <= boundaries(i+1));

                    % If the region is non-empty, calculate the centroid
                    if ~isempty(region) && sum(pdfRegion) > 0
                        newQ(i) = trapz(region, region .* pdfRegion) / trapz(region, pdfRegion);
                    end
                end

                % Check if the change in quantization points is small enough to stop
                if max(abs(newQ - q)) < tol
                    break;
                end

                % Update the quantization points for the next iteration
                q = newQ;
            end

            % Calculate the distortion (how far the data points are from the quantization points)
            distortion = 0;
            for i = 1:numPoints
                % Get the x-values and PDF values for this region
                region = x(x > boundaries(i) & x <= boundaries(i+1));
                pdfRegion = pdfVals(x > boundaries(i) & x <= boundaries(i+1));

                % If the region is non-empty, add its contribution to the distortion
                if ~isempty(region)
                    distortion = distortion + trapz(region, (region - q(i)).^2 .* pdfRegion);
                end
            end

            % Display the results in the GUI
            distortionOutput.Text = num2str(distortion, '%.5f');  % Show distortion value
            pointsOutput.Value = sprintf('%0.5f\n', q);  % List the quantization points

        catch
            % If there's an error (e.g., bad input), show an error message to the user
            uialert(fig, 'Error in computation. Check your inputs.', 'Error');
        end
    end
end
